# Getting started

Add the package, describe your screens as routes and navigate with a router.

## Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/SwiftRouter.git` and add the **SwiftRouter** library to your
app target. In a `Package.swift`:

```swift
.package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "2.0.0")
```

## Describe the screens

Make one enum with a case per screen. Associated values carry what the screen needs, such as an
identifier; keep them small values, not view models, because the router compares and saves them.

```swift
enum AppRoute: Route {
    case product(id: Int)
    case reviews(productID: Int)
    case cart
    case settings

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .product(let id): ProductScreen(id: id)
        case .reviews(let id): ReviewsScreen(productID: id)
        case .cart: CartScreen()
        case .settings: SettingsScreen()
        }
    }
}
```

## Show a router

Keep the router in `@State` of the view that owns the window or tab, and give it to a
``RouterView`` with the root screen:

```swift
struct ContentView: View {
    @State private var router = Router<AppRoute>()

    var body: some View {
        RouterView(router: router) {
            CatalogScreen()
        }
    }
}
```

Screens inside the router view, sheets included, read it from the environment:

```swift
struct ProductScreen: View {
    let id: Int
    @Environment(Router<AppRoute>.self) private var router

    var body: some View {
        VStack {
            RouterLink("Reviews", to: AppRoute.reviews(productID: id))
            Button("Open the cart") { router.present(.cart) }
        }
    }
}
```

## Navigate

| Call                       | What it does                                                      |
| -------------------------- | ----------------------------------------------------------------- |
| ``Router/push(_:)``          | Pushes a screen onto the top-most stack                           |
| ``Router/push(contentsOf:)`` | Pushes several screens in one update                              |
| ``Router/present(_:style:)`` | Shows a sheet or full-screen cover with its own stack             |
| ``Router/pop(_:)``           | Pops pushed screens of the top-most stack; never closes a sheet   |
| ``Router/popToRoot()``       | Pops to the first screen of the top-most stack                    |
| ``Router/popTo(_:)``         | Pops to the last occurrence of a route, across sheets             |
| ``Router/dismiss()``         | Closes the top-most sheet or cover with what was pushed inside it |
| ``Router/dismissAll()``      | Closes every sheet and cover                                      |
| ``Router/reset()``           | Closes everything and pops to the root view                       |
| ``Router/setEntries(_:)``    | Replaces the whole state                                          |

Every call that adds screens returns a ``NavigationOutcome``. It is `.applied` unless a guard
redirected or refused the request (see <doc:GuardingScreens>) or the request is longer than
``Router/maxDepth``, 64 entries by default.

The back button, the swipe back and the swipe down on a sheet update the router, so
``Router/entries`` always describes what is on screen. A `NavigationLink(value:)` with a route
value works too, and goes through the guards like ``Router/push(_:)``.

## Sheets inside sheets

A sheet entry starts a new level with its own `NavigationStack`. Pushes after it stay inside the
sheet; another sheet entry opens on top of it:

```swift
router.setEntries([
    .push(.product(id: 3)),
    .sheet(.cart),
    .push(.settings),
])
```

On macOS, where SwiftUI has no full-screen cover, a ``PresentationStyle/fullScreenCover`` entry is
shown as a sheet.
