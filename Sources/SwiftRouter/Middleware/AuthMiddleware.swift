//
//  AuthMiddleware.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine

// MARK: - Auth State

/// Represents the current authentication state
public enum AuthState: Equatable, Sendable {
    case unknown
    case unauthenticated
    case authenticated(userId: String)
    case authenticating
    case expired
    case locked
    
    /// Whether the user is authenticated
    public var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }
    
    /// User ID if authenticated
    public var userId: String? {
        if case .authenticated(let id) = self { return id }
        return nil
    }
}

// MARK: - Auth Permission

/// Represents an authentication permission
public struct AuthPermission: Hashable, Sendable {
    
    /// Permission identifier
    public let identifier: String
    
    /// Permission scope
    public let scope: PermissionScope
    
    /// Permission level
    public let level: PermissionLevel
    
    /// Permission scope
    public enum PermissionScope: String, Sendable {
        case read
        case write
        case delete
        case admin
        case custom
    }
    
    /// Permission level
    public enum PermissionLevel: Int, Comparable, Sendable {
        case none = 0
        case basic = 1
        case standard = 2
        case elevated = 3
        case admin = 4
        
        public static func < (lhs: PermissionLevel, rhs: PermissionLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    /// Creates a permission
    public init(identifier: String, scope: PermissionScope = .read, level: PermissionLevel = .basic) {
        self.identifier = identifier
        self.scope = scope
        self.level = level
    }
    
    /// Read permission
    public static func read(_ identifier: String) -> AuthPermission {
        AuthPermission(identifier: identifier, scope: .read, level: .basic)
    }
    
    /// Write permission
    public static func write(_ identifier: String) -> AuthPermission {
        AuthPermission(identifier: identifier, scope: .write, level: .standard)
    }
    
    /// Admin permission
    public static func admin(_ identifier: String) -> AuthPermission {
        AuthPermission(identifier: identifier, scope: .admin, level: .admin)
    }
}

// MARK: - Auth Role

/// Represents a user role
public struct AuthRole: Hashable, Sendable {
    
    /// Role identifier
    public let identifier: String
    
    /// Role display name
    public let displayName: String
    
    /// Permissions granted by this role
    public let permissions: Set<AuthPermission>
    
    /// Role priority (higher = more privileged)
    public let priority: Int
    
    /// Creates a role
    public init(
        identifier: String,
        displayName: String,
        permissions: Set<AuthPermission>,
        priority: Int = 0
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.permissions = permissions
        self.priority = priority
    }
    
    /// Guest role
    public static let guest = AuthRole(
        identifier: "guest",
        displayName: "Guest",
        permissions: [],
        priority: 0
    )
    
    /// User role
    public static let user = AuthRole(
        identifier: "user",
        displayName: "User",
        permissions: [.read("profile"), .write("profile")],
        priority: 1
    )
    
    /// Admin role
    public static let admin = AuthRole(
        identifier: "admin",
        displayName: "Administrator",
        permissions: [.admin("all")],
        priority: 100
    )
}

// MARK: - Auth Provider Protocol

/// Protocol for authentication providers
public protocol AuthProvider: Sendable {
    
    /// Current authentication state
    var authState: AuthState { get async }
    
    /// Whether user is authenticated
    var isAuthenticated: Bool { get async }
    
    /// Current user ID
    var currentUserId: String? { get async }
    
    /// Current user roles
    var currentRoles: Set<AuthRole> { get async }
    
    /// Checks if user has permission
    func hasPermission(_ permission: AuthPermission) async -> Bool
    
    /// Checks if user has permission by string
    func hasPermission(_ permission: String) async -> Bool
    
    /// Checks if user has role
    func hasRole(_ role: AuthRole) async -> Bool
    
    /// Checks if user has role by identifier
    func hasRole(_ roleIdentifier: String) async -> Bool
    
    /// Refreshes authentication
    func refreshAuth() async throws
    
    /// Signs out the user
    func signOut() async throws
}

// MARK: - Default Implementations

public extension AuthProvider {
    func hasPermission(_ permission: String) async -> Bool {
        await hasPermission(AuthPermission(identifier: permission))
    }
    
    func hasRole(_ roleIdentifier: String) async -> Bool {
        let roles = await currentRoles
        return roles.contains { $0.identifier == roleIdentifier }
    }
    
    func refreshAuth() async throws {}
    func signOut() async throws {}
}

// MARK: - Auth Requirement

/// Defines authentication requirements for a route
public struct AuthRequirement: Sendable {
    
    /// Requirement type
    public let type: RequirementType
    
    /// Required permissions
    public let permissions: Set<AuthPermission>
    
    /// Required roles (any)
    public let roles: Set<String>
    
    /// Custom validation
    public let customValidator: (@Sendable (any AuthProvider) async -> Bool)?
    
    /// Requirement type
    public enum RequirementType: Sendable {
        case none
        case authenticated
        case permissions
        case roles
        case custom
        case all
    }
    
    /// No authentication required
    public static let none = AuthRequirement(type: .none, permissions: [], roles: [], customValidator: nil)
    
    /// Basic authentication required
    public static let authenticated = AuthRequirement(type: .authenticated, permissions: [], roles: [], customValidator: nil)
    
    /// Creates a permission-based requirement
    public static func permissions(_ perms: Set<AuthPermission>) -> AuthRequirement {
        AuthRequirement(type: .permissions, permissions: perms, roles: [], customValidator: nil)
    }
    
    /// Creates a role-based requirement
    public static func roles(_ roles: Set<String>) -> AuthRequirement {
        AuthRequirement(type: .roles, permissions: [], roles: roles, customValidator: nil)
    }
    
    /// Creates a custom requirement
    public static func custom(_ validator: @escaping @Sendable (any AuthProvider) async -> Bool) -> AuthRequirement {
        AuthRequirement(type: .custom, permissions: [], roles: [], customValidator: validator)
    }
    
    /// Creates a requirement
    public init(
        type: RequirementType,
        permissions: Set<AuthPermission>,
        roles: Set<String>,
        customValidator: (@Sendable (any AuthProvider) async -> Bool)?
    ) {
        self.type = type
        self.permissions = permissions
        self.roles = roles
        self.customValidator = customValidator
    }
}

// MARK: - Auth Middleware Error

/// Errors from auth middleware
public enum AuthMiddlewareError: Error, Sendable, LocalizedError {
    case notAuthenticated(attemptedRoute: String, redirectTo: String)
    case insufficientPermissions(required: Set<AuthPermission>, missing: Set<AuthPermission>)
    case insufficientRole(required: Set<String>, current: Set<String>)
    case sessionExpired
    case accountLocked
    case authRefreshFailed(underlying: Error)
    case customValidationFailed
    case rateLimited(retryAfter: TimeInterval)
    case maintenanceMode
    
    public var errorDescription: String? {
        switch self {
        case .notAuthenticated(let route, let redirect):
            return "Authentication required for \(route). Please sign in at \(redirect)"
        case .insufficientPermissions(let required, let missing):
            return "Missing permissions: \(missing.map { $0.identifier }.joined(separator: ", "))"
        case .insufficientRole(let required, let current):
            return "Required role: \(required.joined(separator: " or "))"
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .accountLocked:
            return "Your account has been locked."
        case .authRefreshFailed(let error):
            return "Failed to refresh authentication: \(error.localizedDescription)"
        case .customValidationFailed:
            return "Custom authorization check failed"
        case .rateLimited(let retryAfter):
            return "Too many requests. Please try again in \(Int(retryAfter)) seconds."
        case .maintenanceMode:
            return "The app is currently under maintenance."
        }
    }
    
    public var redirectRoute: String? {
        switch self {
        case .notAuthenticated(_, let redirect):
            return redirect
        case .sessionExpired:
            return "/login"
        case .accountLocked:
            return "/account-locked"
        default:
            return nil
        }
    }
}

// MARK: - Auth Middleware Configuration

/// Configuration for auth middleware
public struct AuthMiddlewareConfiguration: Sendable {
    
    /// Login route for redirects
    public var loginRoute: String
    
    /// Protected route patterns
    public var protectedPatterns: Set<String>
    
    /// Public route patterns (bypass auth)
    public var publicPatterns: Set<String>
    
    /// Whether to auto-refresh expired tokens
    public var autoRefresh: Bool
    
    /// Whether to cache auth checks
    public var cacheAuthChecks: Bool
    
    /// Cache TTL in seconds
    public var cacheTTL: TimeInterval
    
    /// Rate limiting
    public var enableRateLimiting: Bool
    
    /// Max auth attempts per minute
    public var maxAttemptsPerMinute: Int
    
    /// Whether middleware is enabled
    public var isEnabled: Bool
    
    /// Default configuration
    public static let `default` = AuthMiddlewareConfiguration(
        loginRoute: "/login",
        protectedPatterns: [],
        publicPatterns: ["/login", "/register", "/forgot-password", "/onboarding", "/terms", "/privacy"],
        autoRefresh: true,
        cacheAuthChecks: true,
        cacheTTL: 60,
        enableRateLimiting: true,
        maxAttemptsPerMinute: 30,
        isEnabled: true
    )
    
    /// Creates configuration
    public init(
        loginRoute: String = "/login",
        protectedPatterns: Set<String> = [],
        publicPatterns: Set<String> = [],
        autoRefresh: Bool = true,
        cacheAuthChecks: Bool = true,
        cacheTTL: TimeInterval = 60,
        enableRateLimiting: Bool = true,
        maxAttemptsPerMinute: Int = 30,
        isEnabled: Bool = true
    ) {
        self.loginRoute = loginRoute
        self.protectedPatterns = protectedPatterns
        self.publicPatterns = publicPatterns
        self.autoRefresh = autoRefresh
        self.cacheAuthChecks = cacheAuthChecks
        self.cacheTTL = cacheTTL
        self.enableRateLimiting = enableRateLimiting
        self.maxAttemptsPerMinute = maxAttemptsPerMinute
        self.isEnabled = isEnabled
    }
}

// MARK: - Auth Middleware

/// Middleware that enforces authentication requirements
public struct AuthMiddleware: NavigationMiddleware {
    
    /// Middleware name
    public let name = "AuthMiddleware"
    
    /// Middleware priority (high priority)
    public let priority: Int = 100
    
    /// Whether enabled
    public var isEnabled: Bool { configuration.isEnabled }
    
    private let provider: any AuthProvider
    private let configuration: AuthMiddlewareConfiguration
    private let requirementResolver: (@Sendable (any Route) -> AuthRequirement)?
    private let authCache: AuthCache
    private let rateLimiter: AuthRateLimiter
    
    /// Creates auth middleware
    /// - Parameters:
    ///   - provider: Auth provider
    ///   - configuration: Configuration
    ///   - requirementResolver: Closure to resolve auth requirements per route
    public init(
        provider: any AuthProvider,
        configuration: AuthMiddlewareConfiguration = .default,
        requirementResolver: (@Sendable (any Route) -> AuthRequirement)? = nil
    ) {
        self.provider = provider
        self.configuration = configuration
        self.requirementResolver = requirementResolver
        self.authCache = AuthCache(ttl: configuration.cacheTTL)
        self.rateLimiter = AuthRateLimiter(maxAttempts: configuration.maxAttemptsPerMinute)
    }
    
    /// Handles navigation context
    public func handle(context: NavigationContext) async throws {
        let pattern = type(of: context.route).pattern
        
        // Skip public routes
        if isPublicRoute(pattern: pattern) {
            return
        }
        
        // Rate limiting
        if configuration.enableRateLimiting {
            guard rateLimiter.allowRequest() else {
                throw AuthMiddlewareError.rateLimited(retryAfter: 60)
            }
        }
        
        // Check cache
        if configuration.cacheAuthChecks, let cached = authCache.get(for: pattern) {
            if !cached {
                throw AuthMiddlewareError.notAuthenticated(
                    attemptedRoute: pattern,
                    redirectTo: configuration.loginRoute
                )
            }
            return
        }
        
        // Get auth state
        let authState = await provider.authState
        
        // Handle special states
        switch authState {
        case .expired:
            if configuration.autoRefresh {
                do {
                    try await provider.refreshAuth()
                } catch {
                    throw AuthMiddlewareError.authRefreshFailed(underlying: error)
                }
            } else {
                throw AuthMiddlewareError.sessionExpired
            }
        case .locked:
            throw AuthMiddlewareError.accountLocked
        case .unauthenticated, .unknown:
            if isProtectedRoute(pattern: pattern) {
                authCache.set(false, for: pattern)
                throw AuthMiddlewareError.notAuthenticated(
                    attemptedRoute: pattern,
                    redirectTo: configuration.loginRoute
                )
            }
        case .authenticating:
            // Wait briefly for auth to complete
            try await Task.sleep(nanoseconds: 100_000_000)
        case .authenticated:
            break
        }
        
        // Get requirement
        let requirement: AuthRequirement
        if let resolver = requirementResolver {
            requirement = resolver(context.route)
        } else if isProtectedRoute(pattern: pattern) {
            requirement = .authenticated
        } else {
            requirement = .none
        }
        
        // Validate requirement
        try await validateRequirement(requirement, for: pattern)
        
        // Cache success
        if configuration.cacheAuthChecks {
            authCache.set(true, for: pattern)
        }
    }
    
    /// Called when navigation completes
    public func didComplete(context: NavigationContext) async {
        // Log successful authenticated navigation if needed
    }
    
    /// Called when navigation fails
    public func didFail(context: NavigationContext, error: Error) async {
        // Track auth failures
    }
    
    // MARK: - Private Methods
    
    private func validateRequirement(_ requirement: AuthRequirement, for pattern: String) async throws {
        switch requirement.type {
        case .none:
            return
            
        case .authenticated:
            guard await provider.isAuthenticated else {
                throw AuthMiddlewareError.notAuthenticated(
                    attemptedRoute: pattern,
                    redirectTo: configuration.loginRoute
                )
            }
            
        case .permissions:
            var missing: Set<AuthPermission> = []
            for permission in requirement.permissions {
                if !(await provider.hasPermission(permission)) {
                    missing.insert(permission)
                }
            }
            if !missing.isEmpty {
                throw AuthMiddlewareError.insufficientPermissions(
                    required: requirement.permissions,
                    missing: missing
                )
            }
            
        case .roles:
            let currentRoles = await provider.currentRoles
            let currentRoleIds = Set(currentRoles.map { $0.identifier })
            let hasRequiredRole = !requirement.roles.isDisjoint(with: currentRoleIds)
            
            if !hasRequiredRole {
                throw AuthMiddlewareError.insufficientRole(
                    required: requirement.roles,
                    current: currentRoleIds
                )
            }
            
        case .custom:
            if let validator = requirement.customValidator {
                guard await validator(provider) else {
                    throw AuthMiddlewareError.customValidationFailed
                }
            }
            
        case .all:
            // Validate all aspects
            guard await provider.isAuthenticated else {
                throw AuthMiddlewareError.notAuthenticated(
                    attemptedRoute: pattern,
                    redirectTo: configuration.loginRoute
                )
            }
            
            // Check permissions
            var missing: Set<AuthPermission> = []
            for permission in requirement.permissions {
                if !(await provider.hasPermission(permission)) {
                    missing.insert(permission)
                }
            }
            if !missing.isEmpty {
                throw AuthMiddlewareError.insufficientPermissions(
                    required: requirement.permissions,
                    missing: missing
                )
            }
            
            // Check roles
            if !requirement.roles.isEmpty {
                let currentRoles = await provider.currentRoles
                let currentRoleIds = Set(currentRoles.map { $0.identifier })
                let hasRequiredRole = !requirement.roles.isDisjoint(with: currentRoleIds)
                
                if !hasRequiredRole {
                    throw AuthMiddlewareError.insufficientRole(
                        required: requirement.roles,
                        current: currentRoleIds
                    )
                }
            }
            
            // Custom validation
            if let validator = requirement.customValidator {
                guard await validator(provider) else {
                    throw AuthMiddlewareError.customValidationFailed
                }
            }
        }
    }
    
    private func isProtectedRoute(pattern: String) -> Bool {
        if !configuration.protectedPatterns.isEmpty {
            return configuration.protectedPatterns.contains { wildcardMatch(pattern: $0, path: pattern) }
        }
        return true
    }
    
    private func isPublicRoute(pattern: String) -> Bool {
        configuration.publicPatterns.contains { wildcardMatch(pattern: $0, path: pattern) }
    }
    
    private func wildcardMatch(pattern: String, path: String) -> Bool {
        if pattern.hasSuffix("/*") {
            let prefix = String(pattern.dropLast(2))
            return path.hasPrefix(prefix)
        }
        return pattern == path
    }
}

// MARK: - Auth Cache

private final class AuthCache: @unchecked Sendable {
    private var cache: [String: (result: Bool, expiration: Date)] = [:]
    private let ttl: TimeInterval
    private let lock = NSLock()
    
    init(ttl: TimeInterval) {
        self.ttl = ttl
    }
    
    func get(for pattern: String) -> Bool? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let entry = cache[pattern], Date() < entry.expiration else {
            cache.removeValue(forKey: pattern)
            return nil
        }
        return entry.result
    }
    
    func set(_ result: Bool, for pattern: String) {
        lock.lock()
        defer { lock.unlock() }
        
        cache[pattern] = (result, Date().addingTimeInterval(ttl))
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}

// MARK: - Auth Rate Limiter

private final class AuthRateLimiter: @unchecked Sendable {
    private var attempts: [Date] = []
    private let maxAttempts: Int
    private let window: TimeInterval = 60
    private let lock = NSLock()
    
    init(maxAttempts: Int) {
        self.maxAttempts = maxAttempts
    }
    
    func allowRequest() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        let now = Date()
        attempts = attempts.filter { now.timeIntervalSince($0) < window }
        
        if attempts.count < maxAttempts {
            attempts.append(now)
            return true
        }
        return false
    }
}

// MARK: - Mock Auth Provider

/// Simple auth provider for testing
public actor MockAuthProvider: AuthProvider {
    
    public var authState: AuthState
    public var isAuthenticated: Bool { authState.isAuthenticated }
    public var currentUserId: String? { authState.userId }
    public var currentRoles: Set<AuthRole>
    private var permissions: Set<AuthPermission>
    
    public init(
        isAuthenticated: Bool = false,
        userId: String? = nil,
        roles: Set<AuthRole> = [],
        permissions: Set<AuthPermission> = []
    ) {
        self.authState = isAuthenticated ? .authenticated(userId: userId ?? "test-user") : .unauthenticated
        self.currentRoles = roles
        self.permissions = permissions
    }
    
    public func hasPermission(_ permission: AuthPermission) async -> Bool {
        permissions.contains(permission) || currentRoles.contains { $0.permissions.contains(permission) }
    }
    
    public func hasPermission(_ permission: String) async -> Bool {
        await hasPermission(AuthPermission(identifier: permission))
    }
    
    public func hasRole(_ role: AuthRole) async -> Bool {
        currentRoles.contains(role)
    }
    
    public func hasRole(_ roleIdentifier: String) async -> Bool {
        currentRoles.contains { $0.identifier == roleIdentifier }
    }
    
    public func setAuthenticated(_ authenticated: Bool, userId: String? = nil) {
        authState = authenticated ? .authenticated(userId: userId ?? "test-user") : .unauthenticated
    }
    
    public func addPermission(_ permission: AuthPermission) {
        permissions.insert(permission)
    }
    
    public func addRole(_ role: AuthRole) {
        currentRoles.insert(role)
    }
    
    public func refreshAuth() async throws {}
    public func signOut() async throws {
        authState = .unauthenticated
        currentRoles = []
        permissions = []
    }
}
