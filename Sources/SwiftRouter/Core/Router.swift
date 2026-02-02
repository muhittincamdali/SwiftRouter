// Router.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation
import Combine

// MARK: - Router Configuration

/// Configuration object for the ``Router`` instance.
///
/// Use ``RouterConfiguration`` to customize router behavior including
/// middleware chains, transition defaults, and logging preferences.
public struct RouterConfiguration: Sendable {

    /// Maximum depth of the navigation stack before pruning old entries.
    public var maxStackDepth: Int

    /// Whether to enable verbose debug logging for route resolution.
    public var isDebugLoggingEnabled: Bool

    /// Default transition style applied when none is explicitly specified.
    public var defaultTransitionStyle: TransitionStyle

    /// The scheme used for deep link URL matching (e.g., `"myapp"`).
    public var deepLinkScheme: String

    /// Universal link hosts that the router should handle.
    public var universalLinkHosts: [String]

    /// Time interval after which a pending navigation is considered timed out.
    public var navigationTimeout: TimeInterval

    /// Creates a new router configuration.
    ///
    /// - Parameters:
    ///   - maxStackDepth: Maximum navigation stack depth. Defaults to `50`.
    ///   - isDebugLoggingEnabled: Enable debug logging. Defaults to `false`.
    ///   - defaultTransitionStyle: Default transition. Defaults to `.push`.
    ///   - deepLinkScheme: Deep link scheme. Defaults to `"swiftrouter"`.
    ///   - universalLinkHosts: Universal link hosts. Defaults to empty.
    ///   - navigationTimeout: Navigation timeout interval. Defaults to `10`.
    public init(
        maxStackDepth: Int = 50,
        isDebugLoggingEnabled: Bool = false,
        defaultTransitionStyle: TransitionStyle = .push,
        deepLinkScheme: String = "swiftrouter",
        universalLinkHosts: [String] = [],
        navigationTimeout: TimeInterval = 10
    ) {
        self.maxStackDepth = maxStackDepth
        self.isDebugLoggingEnabled = isDebugLoggingEnabled
        self.defaultTransitionStyle = defaultTransitionStyle
        self.deepLinkScheme = deepLinkScheme
        self.universalLinkHosts = universalLinkHosts
        self.navigationTimeout = navigationTimeout
    }

    /// A default configuration suitable for most applications.
    public static let `default` = RouterConfiguration()
}

// MARK: - Router Delegate

/// Delegate protocol for receiving navigation lifecycle events.
///
/// Implement ``RouterDelegate`` to observe when routes are about to be
/// navigated to, when navigation completes, or when errors occur.
public protocol RouterDelegate: AnyObject, Sendable {

    /// Called before the router begins navigating to a route.
    ///
    /// - Parameters:
    ///   - router: The router instance.
    ///   - route: The target route.
    /// - Returns: `true` to allow navigation, `false` to cancel.
    func router(_ router: Router, shouldNavigateTo route: any Route) async -> Bool

    /// Called after navigation to a route completes successfully.
    ///
    /// - Parameters:
    ///   - router: The router instance.
    ///   - route: The completed route.
    func router(_ router: Router, didNavigateTo route: any Route) async

    /// Called when a navigation attempt fails.
    ///
    /// - Parameters:
    ///   - router: The router instance.
    ///   - error: The error that occurred.
    func router(_ router: Router, didFailWith error: RouterError) async
}

/// Default implementations for ``RouterDelegate`` methods.
public extension RouterDelegate {
    func router(_ router: Router, shouldNavigateTo route: any Route) async -> Bool { true }
    func router(_ router: Router, didNavigateTo route: any Route) async {}
    func router(_ router: Router, didFailWith error: RouterError) async {}
}

// MARK: - Router Error

/// Errors that can occur during navigation.
///
/// ``RouterError`` covers common failure modes including unregistered routes,
/// middleware rejections, and timeout conditions.
public enum RouterError: Error, Sendable, CustomStringConvertible {

    /// The specified route pattern has no registered handler.
    case routeNotFound(String)

    /// A middleware in the chain rejected the navigation request.
    case middlewareRejected(String)

    /// The navigation operation exceeded the configured timeout.
    case navigationTimeout

    /// The navigation stack has reached its maximum configured depth.
    case stackOverflow(maxDepth: Int)

    /// An invalid URL was provided for deep link handling.
    case invalidURL(String)

    /// The route parameters failed validation.
    case invalidParameters(String)

    /// A custom error with an associated message.
    case custom(String)

    /// Navigation was cancelled by the delegate or user.
    case cancelled

    public var description: String {
        switch self {
        case .routeNotFound(let pattern):
            return "Route not found: \(pattern)"
        case .middlewareRejected(let reason):
            return "Middleware rejected navigation: \(reason)"
        case .navigationTimeout:
            return "Navigation timed out"
        case .stackOverflow(let maxDepth):
            return "Navigation stack overflow (max: \(maxDepth))"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidParameters(let detail):
            return "Invalid parameters: \(detail)"
        case .custom(let message):
            return message
        case .cancelled:
            return "Navigation was cancelled"
        }
    }
}

// MARK: - Router

/// The main navigation router that manages route resolution, middleware execution,
/// and navigation stack operations.
///
/// ``Router`` is the central piece of SwiftRouter. It coordinates between registered
/// routes, middleware chains, and the underlying navigation stack to provide
/// type-safe, async navigation.
///
/// ## Usage
///
/// ```swift
/// let router = Router(configuration: .default)
/// router.register(ProfileRoute.self)
/// try await router.navigate(to: ProfileRoute(userId: "123"))
/// ```
///
/// ## Thread Safety
///
/// ``Router`` is designed to be used from the main actor. All navigation operations
/// are `@MainActor` isolated to ensure UI consistency.
@MainActor
public final class Router: ObservableObject {

    // MARK: - Properties

    /// The current router configuration.
    public let configuration: RouterConfiguration

    /// The navigation stack managed by this router.
    @Published public private(set) var navigationStack: NavigationStack

    /// The route registry holding all registered route patterns.
    public let registry: RouteRegistry

    /// The deep link handler for URL-based navigation.
    public let deepLinkHandler: DeepLinkHandler

    /// Ordered middleware chain applied to every navigation request.
    public private(set) var middlewares: [any NavigationMiddleware] = []

    /// The delegate for navigation lifecycle events.
    public weak var delegate: (any RouterDelegate)?

    /// Whether a navigation operation is currently in progress.
    @Published public private(set) var isNavigating: Bool = false

    /// The number of completed navigation operations.
    public private(set) var navigationCount: Int = 0

    /// Publisher that emits whenever a navigation completes.
    public let navigationCompleted = PassthroughSubject<any Route, Never>()

    /// Publisher that emits whenever a navigation error occurs.
    public let navigationFailed = PassthroughSubject<RouterError, Never>()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new router with the specified configuration.
    ///
    /// - Parameter configuration: The router configuration. Defaults to `.default`.
    public init(configuration: RouterConfiguration = .default) {
        self.configuration = configuration
        self.navigationStack = NavigationStack(maxDepth: configuration.maxStackDepth)
        self.registry = RouteRegistry()
        self.deepLinkHandler = DeepLinkHandler(
            scheme: configuration.deepLinkScheme,
            universalLinkHosts: configuration.universalLinkHosts
        )

        if configuration.isDebugLoggingEnabled {
            debugLog("Router initialized with scheme: \(configuration.deepLinkScheme)")
        }
    }

    // MARK: - Middleware

    /// Adds a middleware to the end of the middleware chain.
    ///
    /// Middlewares are executed in order for each navigation request.
    ///
    /// - Parameter middleware: The middleware to add.
    public func use(_ middleware: any NavigationMiddleware) {
        middlewares.append(middleware)
        debugLog("Added middleware: \(type(of: middleware))")
    }

    /// Removes all middlewares from the chain.
    public func removeAllMiddlewares() {
        middlewares.removeAll()
        debugLog("Cleared all middlewares")
    }

    // MARK: - Registration

    /// Registers a route type with the router.
    ///
    /// - Parameter routeType: The route type to register.
    public func register<R: Route>(_ routeType: R.Type) {
        registry.register(routeType)
        debugLog("Registered route: \(routeType)")
    }

    // MARK: - Navigation

    /// Navigates to the specified route.
    ///
    /// This method executes the full navigation pipeline:
    /// 1. Delegate pre-check
    /// 2. Middleware chain execution
    /// 3. Stack operation
    /// 4. Delegate post-notification
    ///
    /// - Parameters:
    ///   - route: The target route.
    ///   - action: The navigation action. Defaults to `.push`.
    ///   - animated: Whether to animate the transition. Defaults to `true`.
    /// - Throws: ``RouterError`` if navigation fails.
    public func navigate(
        to route: any Route,
        action: NavigationAction = .push,
        animated: Bool = true
    ) async throws {
        guard !isNavigating else {
            throw RouterError.custom("Navigation already in progress")
        }

        isNavigating = true
        defer { isNavigating = false }

        // Delegate pre-check
        if let delegate = delegate {
            let shouldProceed = await delegate.router(self, shouldNavigateTo: route)
            guard shouldProceed else {
                throw RouterError.cancelled
            }
        }

        // Run middleware chain
        let context = NavigationContext(
            route: route,
            action: action,
            parameters: route.parameters,
            isAnimated: animated
        )

        for middleware in middlewares {
            do {
                try await middleware.handle(context: context)
            } catch {
                let routerError = RouterError.middlewareRejected("\(type(of: middleware)): \(error)")
                navigationFailed.send(routerError)
                await delegate?.router(self, didFailWith: routerError)
                throw routerError
            }
        }

        // Perform stack operation
        switch action {
        case .push:
            try navigationStack.push(route)
        case .present(let style):
            try navigationStack.present(route, style: style)
        case .pop:
            navigationStack.pop()
        case .popToRoot:
            navigationStack.popToRoot()
        case .dismiss:
            navigationStack.dismiss()
        case .replace:
            try navigationStack.replace(with: route)
        case .deepLink(let url):
            try await handleDeepLink(url)
            return
        }

        navigationCount += 1
        navigationCompleted.send(route)
        await delegate?.router(self, didNavigateTo: route)

        debugLog("Navigated to: \(route.pattern) via \(action)")
    }

    /// Handles a deep link URL by resolving it to a route and navigating.
    ///
    /// - Parameter url: The deep link URL to handle.
    /// - Throws: ``RouterError`` if the URL cannot be resolved.
    public func handleDeepLink(_ url: URL) async throws {
        guard let resolved = deepLinkHandler.resolve(url: url, registry: registry) else {
            throw RouterError.invalidURL(url.absoluteString)
        }

        try await navigate(to: resolved.route, action: .push)
    }

    /// Pops the current route from the navigation stack.
    public func pop() {
        navigationStack.pop()
        debugLog("Popped current route")
    }

    /// Pops to the root of the navigation stack.
    public func popToRoot() {
        navigationStack.popToRoot()
        debugLog("Popped to root")
    }

    /// Dismisses the currently presented route.
    public func dismiss() {
        navigationStack.dismiss()
        debugLog("Dismissed current presentation")
    }

    // MARK: - Debug

    private func debugLog(_ message: String) {
        guard configuration.isDebugLoggingEnabled else { return }
        print("[SwiftRouter] \(message)")
    }
}
