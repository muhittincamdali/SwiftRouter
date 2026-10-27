# Guarding screens

Keep screens behind a condition, such as a signed-in user, on every path that can reach them,
and continue to the requested screen once the condition is met.

## Add a guard

A ``RouteGuard`` looks at each route a change adds and decides: ``GuardDecision/allow``,
``GuardDecision/cancel`` or ``GuardDecision/redirect(_:)`` to other entries. The common case, a
condition for some routes, has a shortcut:

```swift
router.addGuard(.requiring(
    { session.isSignedIn },
    for: { $0.needsAccount },
    otherwise: [.sheet(.signIn)]
))
```

Guards run for ``Router/push(_:)``, ``Router/present(_:style:)``, ``Router/setEntries(_:)``, a deep
link, a restored snapshot and a `NavigationLink(value:)` inside a ``RouterView``. They are checked
in the order you add them, and the first one that does not allow the route decides. Only the
entries a change adds are checked; popping and dismissing are never checked.

Guards are synchronous: the router decides in the same update as the tap, so a protected screen
never appears for a moment before its guard answers. If the decision needs the network, redirect
to a screen that loads and then navigates.

## Continue after signing in

When a guard redirects, the router keeps the original request in ``Router/pending``. Once the user
has signed in, ``Router/resumePending()`` shows it, checking it again:

```swift
struct SignInScreen: View {
    @Environment(Router<AppRoute>.self) private var router
    @Environment(Session.self) private var session

    var body: some View {
        Button("Sign in") {
            session.isSignedIn = true
            if router.resumePending() == nil {
                router.dismiss()
            }
        }
    }
}
```

The pending request replaces the sign-in sheet, so the user lands on the screen they asked for,
for example the order from a deep link, with the screens below it in place. Call
``Router/discardPending()`` when the user cancels.

## Sign out

Screens already on screen are not checked again by themselves. After the user signs out, call
``Router/revalidate()``: it runs the guards over the shown entries and removes the first one that
is no longer allowed, with everything above it. A redirecting guard shows its fallback in their
place.

```swift
session.isSignedIn = false
router.revalidate()
```

## Limits

A request with more entries than ``Router/maxDepth`` (64 unless you pass another value to
``Router/init(entries:maxDepth:)``) is rejected with ``NavigationError/depthLimitExceeded(limit:)``
and changes nothing, whether it comes from code, a deep link or a snapshot. A redirect that would
exceed it is rejected the same way.
