// RouterView.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Router View

/// A SwiftUI view that integrates with the ``Router`` to provide
/// declarative navigation driven by the router's navigation stack.
///
/// ``RouterView`` observes the router's state and automatically renders
/// the appropriate view for the current route using a view builder closure.
///
/// ## Usage
///
/// ```swift
/// RouterView(router: appRouter) { route in
///     switch route {
///     case let home as HomeRoute:
///         HomeView(route: home)
///     case let profile as ProfileRoute:
///         ProfileView(userId: profile.userId)
///     default:
///         NotFoundView()
///     }
/// }
/// ```
public struct RouterView<Content: View>: View {

    /// The router instance.
    @ObservedObject private var router: Router

    /// Builder closure that maps a route to a view.
    private let routeViewBuilder: (any Route) -> Content

    /// Whether to show the navigation bar.
    private let showsNavigationBar: Bool

    /// The navigation title for the root view.
    private let rootTitle: String?

    /// State for sheet presentation
    @State private var sheetRoute: RouteWrapper?
    
    /// State for full screen presentation
    @State private var fullScreenRoute: RouteWrapper?

    /// Creates a router view.
    ///
    /// - Parameters:
    ///   - router: The router to observe.
    ///   - showsNavigationBar: Whether to show the navigation bar. Defaults to `true`.
    ///   - rootTitle: Optional navigation title for the root.
    ///   - content: A closure that builds a view for the given route.
    public init(
        router: Router,
        showsNavigationBar: Bool = true,
        rootTitle: String? = nil,
        @ViewBuilder content: @escaping (any Route) -> Content
    ) {
        self.router = router
        self.showsNavigationBar = showsNavigationBar
        self.rootTitle = rootTitle
        self.routeViewBuilder = content
    }

    public var body: some View {
        SwiftUI.NavigationStack(path: $navigationPath) {
            rootContent
                .navigationDestination(for: RouteWrapper.self) { wrapper in
                    routeViewBuilder(wrapper.route)
                }
        }
        .sheet(item: $sheetRoute) { wrapper in
            routeViewBuilder(wrapper.route)
        }
        #if os(iOS) || os(tvOS) || os(visionOS)
        .fullScreenCover(item: $fullScreenRoute) { wrapper in
            routeViewBuilder(wrapper.route)
        }
        #endif
        .onReceive(router.navigationStack.$modalEntries) { _ in
            updateModalState()
        }
        .environment(\.router, router)
    }

    // MARK: - Private

    @ViewBuilder
    private var rootContent: some View {
        if let rootRoute = router.navigationStack.rootEntry?.route {
            routeViewBuilder(rootRoute)
                .applyIf(rootTitle != nil) { view in
                    view.navigationTitle(rootTitle!)
                }
                #if os(iOS) || os(tvOS)
                .applyIf(!showsNavigationBar) { view in
                    view.toolbar(.hidden, for: .navigationBar)
                }
                #endif
        } else {
            Color.clear
        }
    }

    @State private var navigationPath = NavigationPath()
    
    private func updateModalState() {
        if let modal = router.navigationStack.modalEntries.last {
            switch modal.transitionStyle {
            case .sheet:
                sheetRoute = RouteWrapper(route: modal.route)
                fullScreenRoute = nil
            case .fullScreenCover:
                fullScreenRoute = RouteWrapper(route: modal.route)
                sheetRoute = nil
            default:
                sheetRoute = nil
                fullScreenRoute = nil
            }
        } else {
            sheetRoute = nil
            fullScreenRoute = nil
        }
    }
}

// MARK: - Route Wrapper

/// A hashable wrapper around a route for use with SwiftUI's `NavigationPath`.
struct RouteWrapper: Identifiable, Hashable {

    let id = UUID()
    let route: any Route

    static func == (lhs: RouteWrapper, rhs: RouteWrapper) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Conditional View Modifier

private extension View {

    /// Applies a transformation if the condition is true.
    @ViewBuilder
    func applyIf<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Router Environment Key

/// Environment key for injecting the router into the SwiftUI environment.
private struct RouterEnvironmentKey: EnvironmentKey {
    static let defaultValue: Router? = nil
}

/// Extension to add the router to SwiftUI's `EnvironmentValues`.
public extension EnvironmentValues {

    /// The router instance available in the environment.
    var router: Router? {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}

/// View extension for injecting the router into the environment.
public extension View {

    /// Injects a ``Router`` into the SwiftUI environment.
    ///
    /// - Parameter router: The router instance.
    /// - Returns: A view with the router in its environment.
    func router(_ router: Router) -> some View {
        environment(\.router, router)
    }
}
#endif
