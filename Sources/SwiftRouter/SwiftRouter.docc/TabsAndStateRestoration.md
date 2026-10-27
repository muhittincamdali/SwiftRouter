# Tabs and state restoration

Give each tab its own stack, open deep links in the right tab, and bring the navigation state
back when the system recreates a scene.

## One router per tab

A ``TabRouter`` holds the selected tab and one ``Router`` per tab:

```swift
enum AppTab: String, Hashable, CaseIterable {
    case shop, orders
}

struct TabsView: View {
    @State private var tabs = TabRouter<AppTab, AppRoute>(tabs: AppTab.allCases)

    var body: some View {
        TabView(selection: tabs.selectionBinding) {
            RouterView(router: tabs.router(for: .shop)) { CatalogScreen() }
                .tabItem { Label("Shop", systemImage: "bag") }
                .tag(AppTab.shop)

            RouterView(router: tabs.router(for: .orders)) { OrdersScreen() }
                .tabItem { Label("Orders", systemImage: "shippingbox") }
                .tag(AppTab.orders)
        }
    }
}
```

Choosing the selected tab again pops its stack to the root, as in most iOS apps. Set
``TabRouter/popsToRootOnReselect`` to `false` to keep the stack. ``TabRouter/addGuard(_:)`` adds a
guard to every tab.

## Deep links in tabs

``TabRouter/open(_:using:)`` takes the links of each tab in order and opens the URL in the first
tab whose links match it, selecting that tab:

```swift
.onOpenURL { url in
    tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])
}
```

The tab is selected when its router shows the entries or a guard redirects them, for example to
a sign-in sheet in that tab. When a guard cancels the entries or they are deeper than
``Router/maxDepth``, nothing changes and the selected tab stays as it is.

## Save and restore the state

When the routes are `Codable`, a router can be saved and restored. The
``SwiftUICore/View/routerStateRestoration(_:key:)`` modifier stores the state in the scene's
`@SceneStorage` on every change and restores it when the scene is created again, for example
after the system ended the app in the background:

```swift
RouterView(router: tabs.router(for: .shop)) { CatalogScreen() }
    .routerStateRestoration(tabs.router(for: .shop), key: "shop")
```

Scene storage belongs to one scene, so two windows of the app on iPad, Mac or Vision Pro keep
separate navigation states. Use a different key for every router of a scene.

To store the state elsewhere, use ``Router/snapshotData()`` and ``Router/restore(from:)``
directly. A snapshot is versioned JSON (``RouterSnapshot``). Restoring:

- refuses data larger than 256 KiB before decoding it (``RestorationError/tooLarge(limit:)``),
- refuses other format versions and data that does not decode to your routes, leaving the state
  as it is,
- sends the restored entries through the guards, so a screen saved while the user was signed in
  is not shown after they signed out,
- rejects a snapshot longer than ``Router/maxDepth``.

The pending request of a guard is not saved.
