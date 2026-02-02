// MiddlewareProtocol.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Navigation Middleware Protocol

/// A protocol for implementing navigation middleware.
///
/// Middlewares intercept navigation requests before they are executed,
/// allowing cross-cutting concerns like authentication checks, analytics
/// tracking, logging, and rate limiting.
///
/// ## Middleware Chain
///
/// Middlewares are executed in the order they are added to the ``Router``.
/// If any middleware throws, the navigation is cancelled and subsequent
/// middlewares are not executed.
///
/// ## Example
///
/// ```swift
/// struct LoggingMiddleware: NavigationMiddleware {
///     let name = "Logging"
///     let priority = 100
///
///     func handle(context: NavigationContext) async throws {
///         print("Navigating to: \(context.route.pattern)")
///     }
/// }
/// ```
public protocol NavigationMiddleware: Sendable {

    /// A human-readable name for this middleware.
    var name: String { get }

    /// The priority of this middleware. Higher values execute first when
    /// middlewares are sorted by priority.
    var priority: Int { get }

    /// Whether this middleware is currently enabled.
    var isEnabled: Bool { get }

    /// Handles a navigation context.
    ///
    /// Inspect or modify the navigation context. Throw an error to cancel
    /// the navigation.
    ///
    /// - Parameter context: The current navigation context.
    /// - Throws: Any error to reject the navigation.
    func handle(context: NavigationContext) async throws

    /// Called after navigation completes successfully.
    ///
    /// Use this for post-navigation side effects like analytics or logging.
    ///
    /// - Parameter context: The completed navigation context.
    func didComplete(context: NavigationContext) async

    /// Called when navigation fails.
    ///
    /// - Parameters:
    ///   - context: The failed navigation context.
    ///   - error: The error that caused the failure.
    func didFail(context: NavigationContext, error: Error) async
}

/// Default implementations for optional ``NavigationMiddleware`` methods.
public extension NavigationMiddleware {

    var priority: Int { 0 }
    var isEnabled: Bool { true }

    func didComplete(context: NavigationContext) async {}
    func didFail(context: NavigationContext, error: Error) async {}
}

// MARK: - Middleware Chain

/// Executes a chain of middlewares in order.
///
/// ``MiddlewareChain`` manages the sequential execution of middlewares
/// and provides utilities for building and inspecting the chain.
public struct MiddlewareChain: Sendable {

    /// The ordered list of middlewares.
    public let middlewares: [any NavigationMiddleware]

    /// Creates a middleware chain from the given middlewares.
    ///
    /// - Parameter middlewares: The middlewares to include.
    public init(middlewares: [any NavigationMiddleware]) {
        self.middlewares = middlewares.filter(\.isEnabled)
    }

    /// Executes all middlewares in order with the given context.
    ///
    /// - Parameter context: The navigation context.
    /// - Throws: The first error from any middleware in the chain.
    public func execute(context: NavigationContext) async throws {
        for middleware in middlewares {
            try await middleware.handle(context: context)
        }
    }

    /// Notifies all middlewares of a successful navigation.
    ///
    /// - Parameter context: The completed context.
    public func notifyCompletion(context: NavigationContext) async {
        for middleware in middlewares {
            await middleware.didComplete(context: context)
        }
    }

    /// Notifies all middlewares of a failed navigation.
    ///
    /// - Parameters:
    ///   - context: The failed context.
    ///   - error: The error.
    public func notifyFailure(context: NavigationContext, error: Error) async {
        for middleware in middlewares {
            await middleware.didFail(context: context, error: error)
        }
    }
}

// MARK: - Closure Middleware

/// A convenience middleware that wraps a closure.
///
/// Use ``ClosureMiddleware`` for simple, one-off middleware logic without
/// creating a dedicated type.
///
/// ```swift
/// let logger = ClosureMiddleware(name: "Logger") { context in
///     print("→ \(context.route.pattern)")
/// }
/// router.use(logger)
/// ```
public struct ClosureMiddleware: NavigationMiddleware {

    /// The middleware name.
    public let name: String

    /// The middleware priority.
    public let priority: Int

    /// Whether enabled.
    public let isEnabled: Bool

    private let handler: @Sendable (NavigationContext) async throws -> Void
    private let completionHandler: (@Sendable (NavigationContext) async -> Void)?

    /// Creates a closure-based middleware.
    ///
    /// - Parameters:
    ///   - name: The middleware name.
    ///   - priority: Priority value. Defaults to `0`.
    ///   - isEnabled: Whether enabled. Defaults to `true`.
    ///   - onComplete: Optional completion handler.
    ///   - handler: The middleware handler closure.
    public init(
        name: String,
        priority: Int = 0,
        isEnabled: Bool = true,
        onComplete: (@Sendable (NavigationContext) async -> Void)? = nil,
        handler: @escaping @Sendable (NavigationContext) async throws -> Void
    ) {
        self.name = name
        self.priority = priority
        self.isEnabled = isEnabled
        self.completionHandler = onComplete
        self.handler = handler
    }

    public func handle(context: NavigationContext) async throws {
        try await handler(context)
    }

    public func didComplete(context: NavigationContext) async {
        await completionHandler?(context)
    }
}

// MARK: - Conditional Middleware

/// A middleware that only executes when a condition is met.
///
/// Wraps another middleware and evaluates a predicate before delegating.
public struct ConditionalMiddleware: NavigationMiddleware {

    /// The middleware name.
    public let name: String

    /// The middleware priority.
    public let priority: Int

    /// Whether enabled.
    public let isEnabled: Bool

    private let wrapped: any NavigationMiddleware
    private let condition: @Sendable (NavigationContext) -> Bool

    /// Creates a conditional middleware.
    ///
    /// - Parameters:
    ///   - middleware: The underlying middleware.
    ///   - condition: A predicate that determines whether the middleware should execute.
    public init(
        middleware: any NavigationMiddleware,
        condition: @escaping @Sendable (NavigationContext) -> Bool
    ) {
        self.wrapped = middleware
        self.condition = condition
        self.name = "Conditional(\(middleware.name))"
        self.priority = middleware.priority
        self.isEnabled = middleware.isEnabled
    }

    public func handle(context: NavigationContext) async throws {
        guard condition(context) else { return }
        try await wrapped.handle(context: context)
    }

    public func didComplete(context: NavigationContext) async {
        guard condition(context) else { return }
        await wrapped.didComplete(context: context)
    }

    public func didFail(context: NavigationContext, error: Error) async {
        guard condition(context) else { return }
        await wrapped.didFail(context: context, error: error)
    }
}
