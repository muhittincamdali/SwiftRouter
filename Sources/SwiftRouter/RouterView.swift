import SwiftUI

/// Shows a ``Router``'s state: a `NavigationStack` for the root view, and a sheet or full-screen
/// cover with its own `NavigationStack` for every modal level on top of it.
///
/// ```swift
/// struct ContentView: View {
///     @State private var router = Router<AppRoute>()
///
///     var body: some View {
///         RouterView(router: router) {
///             HomeScreen()
///         }
///     }
/// }
/// ```
///
/// Every screen inside, the sheets included, can read the router with
/// `@Environment(Router<AppRoute>.self)` and use ``RouterLink``. The system back button, the swipe
/// back, a swipe down on a sheet and `NavigationLink(value:)` update the router, and a
/// `NavigationLink` to a guarded route goes through the guards.
public struct RouterView<R: Route, Root: View>: View {
    private let router: Router<R>
    private let root: Root

    /// Creates a router view.
    /// - Parameters:
    ///   - router: The navigation state to show.
    ///   - root: The view at the bottom of the root stack.
    public init(router: Router<R>, @ViewBuilder root: () -> Root) {
        self.router = router
        self.root = root()
    }

    public var body: some View {
        RouterLevel(router: router, level: 0, root: root)
    }
}

/// One navigation stack: the root stack (level 0) or the stack inside a sheet or cover.
struct RouterLevel<R: Route, Root: View>: View {
    let router: Router<R>
    let level: Int
    let root: Root

    var body: some View {
        NavigationStack(path: pathBinding) {
            root.navigationDestination(for: R.self) { route in
                route.view()
            }
        }
        .environment(router)
        .sheet(item: modalBinding(sheets: true)) { item in
            modal(item)
        }
        #if !os(macOS)
        .fullScreenCover(item: modalBinding(sheets: false)) { item in
            modal(item)
        }
        #endif
    }

    private var pathBinding: Binding<[R]> {
        Binding(
            get: { router.pushes(atLevel: level) },
            set: { router.setPushes($0, atLevel: level) }
        )
    }

    private func modalBinding(sheets: Bool) -> Binding<ModalItem<R>?> {
        Binding(
            get: {
                guard let entry = router.modalEntry(atLevel: level + 1) else { return nil }
                return ModalItem.presents(entry, asSheet: sheets) ? ModalItem(entry: entry) : nil
            },
            set: { item in
                // Only a dismissal of what this binding presents removes the level; a cover that
                // replaced a sheet in the same update stays.
                guard item == nil, let entry = router.modalEntry(atLevel: level + 1),
                      ModalItem.presents(entry, asSheet: sheets) else { return }
                router.dismissLevel(level + 1)
            }
        )
    }

    private func modal(_ item: ModalItem<R>) -> AnyView {
        // AnyView ends the recursion of RouterLevel types: a sheet can show another sheet.
        AnyView(RouterLevel<R, R.Content>(router: router, level: level + 1, root: item.entry.route.view()))
    }
}

/// The value a sheet or cover is presented for. A different entry presents a new sheet.
struct ModalItem<R: Route>: Identifiable {
    let entry: RouteEntry<R>
    var id: RouteEntry<R> { entry }

    static func presents(_ entry: RouteEntry<R>, asSheet sheets: Bool) -> Bool {
        // macOS has no full-screen cover, so the sheet binding presents covers there too.
        #if os(macOS)
        return sheets && entry.style.isModal
        #else
        return sheets ? entry.style == .sheet : entry.style == .fullScreenCover
        #endif
    }
}
