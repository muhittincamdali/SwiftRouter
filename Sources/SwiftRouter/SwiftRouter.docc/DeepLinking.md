# Deep linking

Map custom-scheme URLs and universal links to whole navigation states, and refuse the links you
did not plan for.

## Map URLs to routes

A ``DeepLinks`` value holds URL patterns and, for each, a handler that returns the screens to
show from the root up. Return `nil` when a value in the URL is not acceptable; the next matching
pattern is then tried.

```swift
var links = DeepLinks<AppRoute>(schemes: ["shop"], hosts: ["shop.example.com"])
links.add("/products/:id") { match in
    guard let id = match.int("id") else { return nil }
    return [.product(id: id)]
}
links.add("/products/:id/reviews") { match in
    match.int("id").map { [.product(id: $0), .reviews(productID: $0)] }
}
links.add("/cart", entries: { _ in [.sheet(.cart)] })
```

With these patterns, `shop://products/3/reviews` and
`https://shop.example.com/products/3/reviews` both open the product with its reviews on top, so
the back button leads to the product. In a custom-scheme URL the host (`products`) is read as the
first path segment.

| Segment    | Matches                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------- |
| `products` | exactly that segment (case-sensitive unless you pass `literalMatching: .caseInsensitive`) |
| `:id`      | any one segment                                                                           |
| `:tab?`    | one segment or none, only at the end                                                      |
| `*`        | the remaining segments, in ``DeepLinkMatch/rest``                                           |

The most specific pattern is tried first, whatever the order you add them in: `/products/new`
before `/products/:id` before `/products/*`.

## Receive the links

Attach ``SwiftUICore/View/onDeepLink(_:router:perform:)`` to the router view. It handles both
paths a link takes into a SwiftUI app: `onOpenURL` for custom schemes and
`onContinueUserActivity(NSUserActivityTypeBrowsingWeb)` for universal links.

```swift
RouterView(router: router) { CatalogScreen() }
    .onDeepLink(links, router: router) { url, outcome in
        if outcome == .unmatched { openURL(url) }
    }
```

A link replaces the navigation state. Its screens go through the guards, so a link to an account
screen shows the sign-in sheet first (see <doc:GuardingScreens>).

For custom schemes, list the scheme under **URL Types** in the target's Info tab. Universal links
also need the Associated Domains entitlement and an `apple-app-site-association` file on your
server; see Apple's
[Supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains).

Paths from other sources, such as a push notification payload, go through
``Router/open(path:using:)``; the path must start with `/`.

## Read values safely

``DeepLinkMatch`` returns `nil` for anything that does not convert, instead of trapping or
guessing:

- ``DeepLinkMatch/int(_:)`` is `nil` for `4.5`, `12abc` and numbers outside `Int`.
- ``DeepLinkMatch/double(_:)`` and ``DeepLinkMatch/queryDouble(_:)`` are `nil` for `nan`, `inf` and
  values that overflow, so a NaN never reaches a conversion such as `Int(_:)`.
- `value(_:as:)` converts with `init?(_:)`, for example to `UInt8`,
  which is `nil` for `300`.

## What is refused

A URL comes from outside the app, so ``DeepLinks/resolve(_:)`` checks it before any pattern runs
and returns ``DeepLinkResolution/rejected(_:)`` with the reason:

| Input                                                                                 | Rejection                                                                                                                          |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| More than 2,048 bytes, 32 segments or 32 query items (``DeepLinkLimits``)               | ``DeepLinkRejection/urlTooLong(limit:)``, ``DeepLinkRejection/tooManySegments(limit:)``, ``DeepLinkRejection/tooManyQueryItems(limit:)`` |
| `http`, unknown schemes, `https` on a host you did not list or on a port other than 443 | ``DeepLinkRejection/unsupportedScheme``, ``DeepLinkRejection/hostNotAllowed``                                                          |
| A user name or password in the URL                                                    | ``DeepLinkRejection/credentialsNotAllowed``                                                                                          |
| A `.` or `..` segment, written plainly or as `%2e`                                    | ``DeepLinkRejection/dotSegment``                                                                                                     |
| Percent-encoded bytes that are not UTF-8                                              | ``DeepLinkRejection/invalidPercentEncoding``                                                                                         |
| Control characters (`%00`, `%0A`, C1 controls) or bidirectional formatting characters | ``DeepLinkRejection/controlCharacter``                                                                                               |

The length is checked first, so a very long URL is refused before it is split. Segments are
percent-decoded one at a time after the path is split at `/`, so `%2F` stays inside one segment
and cannot add a segment that a pattern or a guard did not expect. `*.example.com` in the hosts
accepts `m.example.com` but neither `example.com` nor `badexample.com`. Hosts are compared in
their ASCII form (`bücher.example.com` arrives as `xn--bcher-kva.example.com`) and are never
percent-decoded: a host with `%`, `_` or an empty label, such as `evil.com%2F.example.com`, is
refused.

Foundation's URL parser rewrites a `%` that is not followed by two hex digits as `%25`, so such a
value arrives literally, for example `%zz`.

## Build links

``URLPattern/path(with:rest:)`` builds the path for a pattern, percent-encoding each value, so the
links you share and the links you match come from the same pattern:

```swift
let path = try URLPattern("/products/:id").path(with: ["id": "42"])  // "/products/42"
```
