<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Latest version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

SwiftRouter is a Swift package for navigation in SwiftUI apps on iOS 17+, macOS 14+, tvOS 17+,
watchOS 10+ and visionOS 1+. You list your screens in an enum, and one `Router` holds the whole
navigation state: the pushed screens, the sheets and full-screen covers on top of them, and the
screens pushed inside those sheets. Deep links map to that state, guards check every screen
before it appears, and each tab can keep its own stack. The package has no dependencies.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="A product screen opened by the link routerdemo://products/2"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="The reviews screen pushed on top of the product by one link"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="The cart presented as a sheet by a link"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="A link to an order while signed out shows the sign-in sheet"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

The screenshots come from the [example app](Examples/RouterDemo) on an iPhone simulator: each
one is the state the router reached from the link below it
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Highlights

- **Typed routes** — screens are enum cases with associated values, so a destination that does
  not exist does not compile.
- **One state for stacks and sheets** — `router.entries` lists every pushed screen, sheet and
  full-screen cover. A sheet has its own navigation stack and can present another sheet. The back
  button, the swipe back and the swipe down on a sheet write back into the router.
- **Deep links to whole states** — `shop://products/42` and
  `https://shop.example.com/products/42` can open the catalog with the product on top, or a sheet.
  Patterns such as `/products/:id` are matched from the most specific, and paths for sharing are
  built from the same patterns.
- **Links are checked before they are used** — length, segment and query limits, `https` only on
  the hosts you list, no `..` segments, no control characters, and typed values that are `nil`
  instead of trapping (`Int` overflow, `nan`, `inf`).
- **Guards that no path skips** — a guard sees every screen added by a push, a sheet, a deep link,
  a restored snapshot or a `NavigationLink`. A redirect to sign-in keeps the request, and
  `resumePending()` opens it after sign-in.
- **Tabs and state restoration** — `TabRouter` keeps one stack per tab and pops to the root when
  the selected tab is chosen again; `routerStateRestoration(_:key:)` saves the state per scene
  and sends it through the guards when it comes back.
- **Tested** — 86 Swift Testing tests on macOS and an iPhone simulator, and 7 UI tests that drive
  the example app on an iOS 27 simulator: push and back, a deep link three screens deep, the
  sign-in sheet on top of the cart sheet, and resuming the request after signing in.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and paste the repository URL into the
search field at the top right:

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

Leave **Dependency Rule** at **Up to Next Major Version** from `2.0.0` and click **Add Package**.
In the next window, choose your app target next to **SwiftRouter** and click **Add Package**
again.

**2. Import the module**

```swift
import SwiftRouter
```

Put this line at the top of each Swift file that uses the router, next to `import SwiftUI`.

**3. Use it**

In a new Xcode app (**File › New › Project… › App**), replace everything in `ContentView.swift`
with:

```swift
import SwiftRouter
import SwiftUI

enum Screen: Route {
    case detail(Int)
    case about

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .detail(let number):
            Text("Item \(number)")
                .navigationTitle("Detail")
        case .about:
            Text("SwiftRouter quick start")
                .navigationTitle("About")
        }
    }
}

struct ContentView: View {
    @State private var router = Router<Screen>()

    var body: some View {
        RouterView(router: router) {
            List {
                RouterLink("Open item 1", to: Screen.detail(1))
                RouterLink("About", to: Screen.about, style: .sheet)
                Button("Open items 2 and 3") {
                    router.push(contentsOf: [.detail(2), .detail(3)])
                }
            }
            .navigationTitle("Home")
        }
    }
}
```

Press **Run** (⌘R). **Open item 1** pushes a screen, **About** opens a sheet (swipe it down to
close it), and **Open items 2 and 3** pushes two screens at once; the back button goes back one
screen at a time.

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter
`https://github.com/muhittincamdali/SwiftRouter.git`, or add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftRouter", package: "SwiftRouter")
    ])
]
```

### Requirements

| | Minimum |
| --- | --- |
| Swift | 6.2 (Xcode 26 or later) |
| Platforms | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

Version 2.0.0 replaces the API of 1.0.0 (February 2026), which looked routes up by string at run
time. In June 2026 the 1.0.0 sources were replaced with placeholder code; 2.0.0 is a new router
built and tested for the Swift 6 language mode, and it takes over the presentation, tab and
state-saving features of SwiftUI-Navigation-Pro. [CHANGELOG.md](CHANGELOG.md) lists the changes and
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
maps the old API to the new one.

## Usage

The samples below are copied from
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift).
The example app and the test suite both compile that file, and the tests run the deep link and
sign-in samples.

### Navigate

Screens inside a `RouterView`, sheets included, read the router from the environment:

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Call | What it does |
| --- | --- |
| `push(_:)`, `push(contentsOf:)` | Pushes one or more screens onto the top-most stack |
| `present(_:style:)` | Shows a `.sheet` or `.fullScreenCover` with its own stack |
| `pop(_:)`, `popToRoot()` | Pops pushed screens of the top-most stack; never closes a sheet |
| `popTo(_:)` | Pops to the last occurrence of a route, across sheets |
| `dismiss()`, `dismissAll()` | Closes the top-most sheet, or every sheet |
| `reset()` | Closes everything and pops to the root view |
| `setEntries(_:)` | Replaces the whole state, for example `[.push(.product(id: 3)), .sheet(.cart)]` |

Each call that adds screens returns `.applied`, `.redirected` (a guard showed something else),
`.cancelled` (a guard refused) or `.rejected` (more than `maxDepth` entries, 64 by default).

### Deep links

```swift
enum ShopRoute: Route, Codable {
    case catalog
    case product(id: Int)
    case cart
    case orders
    case signIn

    var needsAccount: Bool { self == .orders }

    func view() -> some View {
        Text(String(describing: self))
    }
}

func makeShopLinks() -> DeepLinks<ShopRoute> {
    var links = DeepLinks<ShopRoute>(schemes: ["shop"], hosts: ["shop.example.com"])
    links.add("/products/:id") { match in
        guard let id = match.int("id") else { return nil }
        return [.catalog, .product(id: id)]
    }
    links.add("/cart", entries: { _ in [.sheet(.cart)] })
    links.add("/orders") { _ in [.orders] }
    return links
}

struct ShopView: View {
    @State private var router = Router<ShopRoute>()
    private let links = makeShopLinks()

    var body: some View {
        RouterView(router: router) {
            Text("Home")
        }
        .onDeepLink(links, router: router)
    }
}
```

`shop://products/42` and `https://shop.example.com/products/42` both open the catalog with
product 42 on top, so the back button leads to the catalog. In a custom-scheme URL the host is
read as the first path segment. `onDeepLink` receives custom schemes through `onOpenURL` and
universal links through `onContinueUserActivity`. Register the scheme under **URL Types** in your
target; universal links also need the Associated Domains entitlement.

A handler returns `nil` when a value is not acceptable, and the next matching pattern is tried.
A link that matches no pattern, or that is refused, leaves the navigation state as it is.

### Guards

```swift
@MainActor
@Observable
final class AccountSession {
    var isSignedIn = false
}

@MainActor
func protectOrders(_ router: Router<ShopRoute>, session: AccountSession) {
    router.addGuard(.requiring(
        { session.isSignedIn },
        for: { $0.needsAccount },
        otherwise: [.sheet(.signIn)]
    ))
}

@MainActor
func signIn(_ router: Router<ShopRoute>, session: AccountSession) {
    session.isSignedIn = true
    if router.resumePending() == nil {
        router.dismiss()
    }
}
```

While signed out, `shop://orders` shows the sign-in sheet and keeps the request. `signIn` then
replaces the sheet with the orders screen. After signing out, call `router.revalidate()` to
remove the screens that are no longer allowed.

### Tabs and state restoration

```swift
enum AppTab: String, Hashable, CaseIterable {
    case shop, orders
}

struct TabsView: View {
    @State private var tabs = TabRouter<AppTab, ShopRoute>(tabs: AppTab.allCases)

    var body: some View {
        TabView(selection: tabs.selectionBinding) {
            RouterView(router: tabs.router(for: .shop)) {
                Text("Catalog")
            }
            .routerStateRestoration(tabs.router(for: .shop), key: "shop")
            .tabItem { Label("Shop", systemImage: "bag") }
            .tag(AppTab.shop)

            RouterView(router: tabs.router(for: .orders)) {
                Text("Orders")
            }
            .routerStateRestoration(tabs.router(for: .orders), key: "orders")
            .tabItem { Label("Orders", systemImage: "shippingbox") }
            .tag(AppTab.orders)
        }
    }
}
```

Each tab keeps its own stack, and choosing the selected tab again pops it to the root.
`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` opens a link in the first tab
whose links match it. The state is saved in the scene's storage, so each window keeps its own,
and it comes back after the system ends the app in the background. The routes must be `Codable`
for that.

## How links are checked

A URL comes from outside the app, so `DeepLinks` checks it before any pattern runs:

| Input | Result |
| --- | --- |
| Longer than 2,048 bytes, more than 32 segments or 32 query items | Refused; the length is checked first |
| `http`, an unknown scheme, `https` on a host you did not list | Refused; `*.example.com` accepts subdomains only |
| A user name or password in the URL | Refused |
| A `.` or `..` segment, also written as `%2e` | Refused, not resolved |
| `%2F` | Stays inside one segment |
| Control characters, bidirectional formatting characters, bytes that are not UTF-8 | Refused |
| `nan`, `inf`, `4.5` or `99999999999999999999` read with `int` or `double` | `nil` |

The limits are set with `DeepLinkLimits`. The package never prints or logs URLs or routes; links
can carry sign-in or reset tokens. The
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
article lists every rule.

## Example app

[`Examples/RouterDemo`](Examples/RouterDemo) is a small shop for iOS and macOS: a Shop and an
Account tab, products with reviews, a cart sheet, orders behind a sign-in guard, deep links on
the `routerdemo://` scheme and saved state. Open `Examples/RouterDemo/RouterDemo.xcodeproj`,
choose the **RouterDemo** scheme and an iPhone simulator or **My Mac**, and press **Run** (⌘R).
To try a link on the simulator:

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

The **RouterDemoUITests** target (⌘U on an iPhone simulator) checks the flows on screen.

## Documentation

The [documentation](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/)
covers every public type, with these articles:

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Contributing

Bug reports and pull requests are welcome; [CONTRIBUTING.md](CONTRIBUTING.md) explains how to
run the tests and the example app. Report security issues privately as described in
[SECURITY.md](SECURITY.md).

## License

SwiftRouter is available under the MIT license. See [LICENSE](LICENSE).
