// AuthMiddleware.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Auth Provider Protocol

/// A protocol for providing authentication state to the ``AuthMiddleware``.
///
/// Implement this protocol to connect your authentication system with
/// the router's auth middleware.
public protocol AuthProvider: Sendable {

    /// Whether the user is currently authenticated.
    var isAuthenticated: Bool { get async }

    /// The current user's identifier, if authenticated.
    var currentUserId: String? { get async }

    /// Whether the user has the specified permission.
    ///
    /// - Parameter permission: The permission to check.
    /// - Returns: `true` if the user has the permission.
    func hasPermission(_ permission: String) async -> Bool
}

// MARK: - Auth Middleware

/// Middleware that checks authentication before allowing navigation.
///
/// ``AuthMiddleware`` inspects the target route to determine if authentication
/// is required, and rejects navigation if the user is not authenticated.
///
/// Routes that require authentication should have their ``RouteDefinition``
/// configured with `requiresAuth: true`, or their pattern should be included
/// in the middleware's ``protectedPatterns``.
///
/// ## Example
///
/// ```swift
/// let authMiddleware = AuthMiddleware(
///     provider: myAuthProvider,
///     loginRoute: "/login",
///     protectedPatterns: ["/profile/*", "/settings/*"]
/// )
/// router.use(authMiddleware)
/// ```
public struct AuthMiddleware: NavigationMiddleware {

    /// The middleware name.
    public let name = "AuthMiddleware"

    /// The middleware priority. Auth checks run with high priority.
    public let priority: Int = 100

    /// Whether this middleware is enabled.
    public let isEnabled: Bool

    /// The authentication provider.
    private let provider: any AuthProvider

    /// The route pattern to redirect to when not authenticated.
    private let loginRoute: String

    /// Route patterns that require authentication (supports wildcards).
    private let protectedPatterns: [String]

    /// Route patterns that are explicitly public (bypass auth checks).
    private let publicPatterns: [String]

    /// Creates an auth middleware.
    ///
    /// - Parameters:
    ///   - provider: The authentication provider.
    ///   - loginRoute: Login redirect pattern. Defaults to `"/login"`.
    ///   - protectedPatterns: Patterns requiring auth. Defaults to empty (uses route definition).
    ///   - publicPatterns: Patterns that bypass auth. Defaults to common public routes.
    ///   - isEnabled: Whether enabled. Defaults to `true`.
    public init(
        provider: any AuthProvider,
        loginRoute: String = "/login",
        protectedPatterns: [String] = [],
        publicPatterns: [String] = ["/login", "/register", "/forgot-password", "/onboarding"],
        isEnabled: Bool = true
    ) {
        self.provider = provider
        self.loginRoute = loginRoute
        self.protectedPatterns = protectedPatterns
        self.publicPatterns = publicPatterns
        self.isEnabled = isEnabled
    }

    public func handle(context: NavigationContext) async throws {
        let pattern = type(of: context.route).pattern

        // Skip auth check for explicitly public routes
        if isPublicRoute(pattern: pattern) {
            return
        }

        // Check if this route requires authentication
        let requiresAuth = isProtectedRoute(pattern: pattern)

        guard requiresAuth else { return }

        // Verify authentication
        let isAuthenticated = await provider.isAuthenticated
        guard isAuthenticated else {
            throw AuthMiddlewareError.notAuthenticated(
                attemptedRoute: pattern,
                redirectTo: loginRoute
            )
        }
    }

    public func didComplete(context: NavigationContext) async {
        // Could log successful authenticated navigations here
    }

    public func didFail(context: NavigationContext, error: Error) async {
        // Could track failed auth attempts here
    }

    // MARK: - Private

    private func isProtectedRoute(pattern: String) -> Bool {
        if !protectedPatterns.isEmpty {
            return protectedPatterns.contains { wildcardMatch(pattern: $0, path: pattern) }
        }
        // No explicit protected patterns — all non-public routes require auth
        return true
    }

    private func isPublicRoute(pattern: String) -> Bool {
        publicPatterns.contains { wildcardMatch(pattern: $0, path: pattern) }
    }

    private func wildcardMatch(pattern: String, path: String) -> Bool {
        if pattern.hasSuffix("/*") {
            let prefix = String(pattern.dropLast(2))
            return path.hasPrefix(prefix)
        }
        return pattern == path
    }
}

// MARK: - Auth Middleware Error

/// Errors specific to the ``AuthMiddleware``.
public enum AuthMiddlewareError: Error, Sendable, CustomStringConvertible {

    /// The user is not authenticated.
    case notAuthenticated(attemptedRoute: String, redirectTo: String)

    /// The user lacks a required permission.
    case insufficientPermissions(permission: String)

    /// The auth session has expired.
    case sessionExpired

    public var description: String {
        switch self {
        case .notAuthenticated(let route, let redirect):
            return "Not authenticated for \(route). Redirect to \(redirect)"
        case .insufficientPermissions(let permission):
            return "Missing permission: \(permission)"
        case .sessionExpired:
            return "Authentication session has expired"
        }
    }
}
