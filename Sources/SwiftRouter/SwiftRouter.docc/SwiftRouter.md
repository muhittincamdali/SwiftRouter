# ``SwiftRouter``

Type-safe navigation for SwiftUI: one router for stacks, sheets and full-screen covers, deep links mapped to whole navigation states, guards that no path can skip, tabs and state restoration.

## Overview

You describe your screens as an enum that conforms to ``Route``, keep a ``Router`` in `@State`
and show it with a ``RouterView``. The router holds the whole navigation state as an array of
``RouteEntry`` values: pushed screens, and sheets or full-screen covers that each start a new
navigation stack. Changing that array is the only way to navigate, and every change runs through
the ``RouteGuard``s you add, whether it comes from a button, a deep link, a restored snapshot or
SwiftUI's own `NavigationLink`.

```swift
import SwiftRouter
import SwiftUI

enum AppRoute: Route {
    case product(id: Int)
    case cart

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .product(let id): Text("Product \(id)")
        case .cart: Text("Cart")
        }
    }
}

struct ContentView: View {
    @State private var router = Router<AppRoute>()

    var body: some View {
        RouterView(router: router) {
            List {
                RouterLink("Product 1", to: AppRoute.product(id: 1))
                RouterLink("Cart", to: AppRoute.cart, style: .sheet)
            }
        }
    }
}
```

The package has no dependencies, never writes to the console and supports iOS 17, macOS 14,
tvOS 17, watchOS 10 and visionOS 1 or later.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DeepLinking>
- <doc:GuardingScreens>
- <doc:TabsAndStateRestoration>
- <doc:MigratingFromVersion1>

### Routes and the router

- ``Route``
- ``RouteEntry``
- ``PresentationStyle``
- ``Router``
- ``NavigationOutcome``
- ``NavigationError``

### Views

- ``RouterView``
- ``RouterLink``

### Guards

- ``RouteGuard``
- ``GuardDecision``
- ``GuardContext``

### Deep links

- ``DeepLinks``
- ``DeepLinkMatch``
- ``DeepLinkResolution``
- ``DeepLinkOutcome``
- ``DeepLinkRejection``
- ``DeepLinkLimits``
- ``URLPattern``
- ``URLPatternError``

### Tabs and saved state

- ``TabRouter``
- ``RouterSnapshot``
- ``RestorationError``
