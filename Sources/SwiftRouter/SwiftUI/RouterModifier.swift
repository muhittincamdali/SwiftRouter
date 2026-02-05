// RouterModifier.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

#if canImport(SwiftUI)
import SwiftUI
import Combine

// MARK: - On Route Change Modifier

/// A view modifier that executes an action when the router's top route changes.
///
/// Use this modifier to react to navigation events in any view that has
/// a ``Router`` in its environment.
struct OnRouteChangeModifier: ViewModifier {

    @Environment(\.router) private var router
    let action: (any Route) -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(routePublisher) { route in
                action(route)
            }
    }

    private var routePublisher: AnyPublisher<any Route, Never> {
        guard let router = router else {
            return Empty().eraseToAnyPublisher()
        }
        return router.navigationCompleted.eraseToAnyPublisher()
    }
}

// MARK: - On Deep Link Modifier

/// A view modifier that handles deep link URLs.
struct OnDeepLinkModifier: ViewModifier {

    @Environment(\.router) private var router
    let handler: (URL) async -> Bool

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                Task {
                    if let router = router {
                        try? await router.handleDeepLink(url)
                    } else {
                        _ = await handler(url)
                    }
                }
            }
    }
}

// MARK: - Router Navigation Bar Modifier (iOS/tvOS only)

#if os(iOS) || os(tvOS)
/// A view modifier that configures navigation bar appearance based on route.
struct RouterNavigationBarModifier: ViewModifier {

    let title: String
    let displayMode: NavigationBarItem.TitleDisplayMode
    let showsBackButton: Bool

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
            .navigationBarBackButtonHidden(!showsBackButton)
    }
}
#endif

// MARK: - Router Sheet Modifier

/// A view modifier that presents a route as a sheet.
struct RouterSheetModifier<SheetContent: View>: ViewModifier {

    @ObservedObject var router: Router
    let routeType: any Route.Type
    let content: (any Route) -> SheetContent

    @State private var presentedRoute: (any Route)?

    func body(content: Content) -> some View {
        content
            .onReceive(router.navigationCompleted) { route in
                if type(of: route).pattern == routeType.pattern {
                    presentedRoute = route
                }
            }
            .sheet(isPresented: Binding(
                get: { presentedRoute != nil },
                set: { if !$0 { presentedRoute = nil } }
            )) {
                if let route = presentedRoute {
                    self.content(route)
                }
            }
    }
}

// MARK: - Navigation State Modifier

/// A view modifier that provides navigation state information.
struct NavigationStateModifier: ViewModifier {

    @ObservedObject var router: Router

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if router.isNavigating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
    }
}

// MARK: - View Extensions

public extension View {

    /// Executes an action when the router navigates to a new route.
    ///
    /// - Parameter action: The closure to execute with the new route.
    /// - Returns: A modified view.
    func onRouteChange(_ action: @escaping (any Route) -> Void) -> some View {
        modifier(OnRouteChangeModifier(action: action))
    }

    /// Handles deep link URLs.
    ///
    /// - Parameter handler: An async closure that processes the URL.
    /// - Returns: A modified view.
    func onDeepLink(_ handler: @escaping (URL) async -> Bool) -> some View {
        modifier(OnDeepLinkModifier(handler: handler))
    }

    #if os(iOS) || os(tvOS)
    /// Configures the navigation bar for a routed view.
    ///
    /// - Parameters:
    ///   - title: The navigation title.
    ///   - displayMode: Title display mode. Defaults to `.automatic`.
    ///   - showsBackButton: Whether to show the back button. Defaults to `true`.
    /// - Returns: A modified view.
    func routerNavigationBar(
        title: String,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic,
        showsBackButton: Bool = true
    ) -> some View {
        modifier(RouterNavigationBarModifier(
            title: title,
            displayMode: displayMode,
            showsBackButton: showsBackButton
        ))
    }
    #endif

    /// Shows a loading indicator when the router is navigating.
    ///
    /// - Parameter router: The router to observe.
    /// - Returns: A modified view.
    func showsNavigationProgress(router: Router) -> some View {
        modifier(NavigationStateModifier(router: router))
    }
}
#endif
