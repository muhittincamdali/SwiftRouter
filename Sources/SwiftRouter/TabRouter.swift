import Observation
import SwiftUI

/// The selected tab and one ``Router`` per tab, so each tab keeps its own stack.
///
/// ```swift
/// enum AppTab: Hashable { case home, search, account }
///
/// @State private var tabs = TabRouter<AppTab, AppRoute>(tabs: [.home, .search, .account])
///
/// var body: some View {
///     TabView(selection: tabs.selectionBinding) {
///         RouterView(router: tabs.router(for: .home)) { HomeScreen() }
///             .tabItem { Label("Home", systemImage: "house") }
///             .tag(AppTab.home)
///         // …
///     }
/// }
/// ```
///
/// Choosing the tab that is already selected pops its stack to the root, as in most iOS apps;
/// set ``popsToRootOnReselect`` to `false` to turn that off.
@MainActor
@Observable
public final class TabRouter<Tab: Hashable, R: Route> {
    /// The tabs, in order.
    public let tabs: [Tab]
    /// The selected tab. Setting it directly does not pop on reselect; use ``select(_:)``.
    public var selection: Tab
    /// Whether choosing the selected tab again pops its stack to the root.
    public var popsToRootOnReselect = true

    private let routers: [Tab: Router<R>]

    /// Creates a tab router.
    /// - Parameters:
    ///   - tabs: The tabs, without duplicates; at least one.
    ///   - selection: The tab selected first; the first tab when `nil`.
    ///   - maxDepth: The ``Router/maxDepth`` of every tab's router.
    public init(tabs: [Tab], selection: Tab? = nil, maxDepth: Int = Router<R>.defaultMaxDepth) {
        precondition(!tabs.isEmpty, "TabRouter needs at least one tab")
        precondition(Set(tabs).count == tabs.count, "TabRouter tabs must be unique")
        let selected = selection ?? tabs[0]
        precondition(tabs.contains(selected), "The selected tab must be one of the tabs")
        self.tabs = tabs
        self.selection = selected
        self.routers = Dictionary(uniqueKeysWithValues: tabs.map { ($0, Router<R>(maxDepth: maxDepth)) })
    }

    /// The router of `tab`.
    public func router(for tab: Tab) -> Router<R> {
        guard let router = routers[tab] else { preconditionFailure("\(tab) is not one of the tabs") }
        return router
    }

    /// The router of the selected tab.
    public var selectedRouter: Router<R> { router(for: selection) }

    /// Selects `tab`; when it is already selected, pops its stack to the root.
    public func select(_ tab: Tab) {
        if tab == selection, popsToRootOnReselect {
            router(for: tab).popToRoot()
        }
        selection = tab
    }

    /// A binding for `TabView(selection:)` that goes through ``select(_:)``.
    public var selectionBinding: Binding<Tab> {
        Binding(get: { self.selection }, set: { self.select($0) })
    }

    /// Adds a guard to the router of every tab.
    public func addGuard(_ routeGuard: RouteGuard<R>) {
        routers.values.forEach { $0.addGuard(routeGuard) }
    }

    /// Opens a URL in the first tab whose links match it, selecting that tab.
    ///
    /// Returns the outcome of that tab, `.unmatched` when no tab matched, or the first rejection
    /// when every tab refused the URL.
    @discardableResult
    public func open(_ url: URL, using links: KeyValuePairs<Tab, DeepLinks<R>>) -> DeepLinkOutcome {
        var rejection: DeepLinkRejection?
        var anyUnmatched = false
        for (tab, tabLinks) in links {
            switch tabLinks.resolve(url) {
            case .matched(let entries, _):
                selection = tab
                return .navigated(router(for: tab).setEntries(entries))
            case .unmatched:
                anyUnmatched = true
            case .rejected(let reason):
                rejection = rejection ?? reason
            }
        }
        if anyUnmatched { return .unmatched }
        return rejection.map(DeepLinkOutcome.rejected) ?? .unmatched
    }
}
