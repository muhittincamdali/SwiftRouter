// RouteRegistry.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Route Registry

/// A thread-safe registry for storing and resolving route definitions.
///
/// ``RouteRegistry`` maintains a collection of registered routes, enabling
/// pattern-based lookup, priority-based matching, and route validation.
///
/// ## Usage
///
/// ```swift
/// let registry = RouteRegistry()
/// registry.register(ProfileRoute.self)
/// registry.register(SettingsRoute.self, priority: 10)
///
/// if let definition = registry.resolve(path: "/profile/123") {
///     let route = try definition.createRoute(from: params)
/// }
/// ```
public final class RouteRegistry: @unchecked Sendable {

    // MARK: - Properties

    /// All registered route definitions.
    public var allDefinitions: [RouteDefinition] {
        lock.lock()
        defer { lock.unlock() }
        return Array(definitions.values)
    }

    /// The number of registered routes.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return definitions.count
    }

    /// Whether the registry is empty.
    public var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return definitions.isEmpty
    }

    private var definitions: [String: RouteDefinition] = [:]
    private var sortedDefinitions: [RouteDefinition] = []
    private let lock = NSLock()
    private let pathMatcher = PathMatcher()

    // MARK: - Initialization

    /// Creates a new route registry.
    public init() {}

    // MARK: - Registration

    /// Registers a route type.
    ///
    /// - Parameters:
    ///   - routeType: The route type to register.
    ///   - priority: Optional priority override.
    ///   - requiresAuth: Whether the route requires authentication.
    ///   - metadata: Additional metadata.
    public func register<R: Route>(
        _ routeType: R.Type,
        priority: Int = 0,
        requiresAuth: Bool = false,
        metadata: [String: String] = [:]
    ) {
        let pattern = routeType.pattern

        let definition = RouteDefinition(
            pattern: pattern,
            name: String(describing: routeType),
            priority: priority,
            requiresAuth: requiresAuth,
            metadata: metadata
        ) { parameters in
            try R(parameters: parameters)
        }

        register(definition)
    }

    /// Registers a route definition directly.
    ///
    /// - Parameter definition: The route definition to register.
    public func register(_ definition: RouteDefinition) {
        lock.lock()
        defer { lock.unlock() }

        definitions[definition.pattern] = definition
        rebuildSortedDefinitions()
    }

    /// Registers multiple route types.
    ///
    /// - Parameter routeTypes: The route types to register.
    public func registerAll(_ routeTypes: [any Route.Type]) {
        for routeType in routeTypes {
            registerRouteType(routeType)
        }
    }

    /// Unregisters a route pattern.
    ///
    /// - Parameter pattern: The pattern to unregister.
    /// - Returns: The removed definition, if any.
    @discardableResult
    public func unregister(pattern: String) -> RouteDefinition? {
        lock.lock()
        defer { lock.unlock() }

        let removed = definitions.removeValue(forKey: pattern)
        if removed != nil {
            rebuildSortedDefinitions()
        }
        return removed
    }

    /// Removes all registered routes.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        definitions.removeAll()
        sortedDefinitions.removeAll()
    }

    // MARK: - Lookup

    /// Gets the definition for a specific pattern.
    ///
    /// - Parameter pattern: The exact pattern to look up.
    /// - Returns: The route definition, or `nil`.
    public func definition(for pattern: String) -> RouteDefinition? {
        lock.lock()
        defer { lock.unlock() }
        return definitions[pattern]
    }

    /// Resolves a path to a matching route definition.
    ///
    /// - Parameter path: The URL path to resolve.
    /// - Returns: A tuple of the matching definition and extracted parameters, or `nil`.
    public func resolve(path: String) -> (definition: RouteDefinition, parameters: RouteParameters)? {
        lock.lock()
        let defs = sortedDefinitions
        lock.unlock()

        for definition in defs {
            if let params = pathMatcher.extractParameters(pattern: definition.pattern, path: path) {
                return (definition, params)
            }
        }

        return nil
    }

    /// Checks whether a pattern is registered.
    ///
    /// - Parameter pattern: The pattern to check.
    /// - Returns: `true` if the pattern is registered.
    public func isRegistered(pattern: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return definitions[pattern] != nil
    }

    /// Finds all routes matching a predicate.
    ///
    /// - Parameter predicate: A closure that evaluates each definition.
    /// - Returns: The matching definitions.
    public func find(where predicate: (RouteDefinition) -> Bool) -> [RouteDefinition] {
        lock.lock()
        defer { lock.unlock() }
        return definitions.values.filter(predicate)
    }

    /// Returns all routes that require authentication.
    public func authRequiredRoutes() -> [RouteDefinition] {
        find { $0.requiresAuth }
    }

    /// Returns all routes matching a pattern prefix.
    ///
    /// - Parameter prefix: The pattern prefix (e.g., `/api/`).
    /// - Returns: The matching definitions.
    public func routes(withPrefix prefix: String) -> [RouteDefinition] {
        find { $0.pattern.hasPrefix(prefix) }
    }

    // MARK: - Validation

    /// Validates that all registered patterns are well-formed.
    ///
    /// - Returns: An array of validation errors, empty if all valid.
    public func validate() -> [RegistryValidationError] {
        lock.lock()
        let defs = Array(definitions.values)
        lock.unlock()

        var errors: [RegistryValidationError] = []

        for definition in defs {
            if !pathMatcher.isValidPattern(definition.pattern) {
                errors.append(.invalidPattern(definition.pattern))
            }
        }

        // Check for ambiguous patterns
        let patterns = defs.map(\.pattern)
        for (index, pattern) in patterns.enumerated() {
            for otherPattern in patterns.dropFirst(index + 1) {
                if couldConflict(pattern, otherPattern) {
                    errors.append(.ambiguousPatterns(pattern, otherPattern))
                }
            }
        }

        return errors
    }

    // MARK: - Debug

    /// Returns a debug description of all registered routes.
    public func debugDescription() -> String {
        lock.lock()
        let defs = sortedDefinitions
        lock.unlock()

        var lines = ["RouteRegistry (\(defs.count) routes):"]
        for def in defs {
            let authMark = def.requiresAuth ? "🔒" : "  "
            lines.append("  \(authMark) [\(def.priority)] \(def.pattern) → \(def.name)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private func registerRouteType(_ routeType: any Route.Type) {
        let pattern = routeType.pattern
        let definition = RouteDefinition(
            pattern: pattern,
            name: String(describing: routeType),
            priority: 0,
            requiresAuth: false,
            metadata: [:]
        ) { parameters in
            try createRouteInstance(routeType, parameters: parameters)
        }
        register(definition)
    }

    private func rebuildSortedDefinitions() {
        // Sort by: 1) priority (descending), 2) specificity (descending), 3) pattern (alphabetically)
        sortedDefinitions = definitions.values.sorted { a, b in
            if a.priority != b.priority {
                return a.priority > b.priority
            }
            let aSpecificity = pathMatcher.specificity(of: a.pattern)
            let bSpecificity = pathMatcher.specificity(of: b.pattern)
            if aSpecificity != bSpecificity {
                return aSpecificity > bSpecificity
            }
            return a.pattern < b.pattern
        }
    }

    private func couldConflict(_ pattern1: String, _ pattern2: String) -> Bool {
        // Two patterns conflict if they could match the same path
        // This is a simplified check - a real implementation would be more thorough
        let segments1 = pattern1.split(separator: "/").map(String.init)
        let segments2 = pattern2.split(separator: "/").map(String.init)

        guard segments1.count == segments2.count else { return false }

        for (s1, s2) in zip(segments1, segments2) {
            let s1IsParam = s1.hasPrefix(":")
            let s2IsParam = s2.hasPrefix(":")

            if !s1IsParam && !s2IsParam && s1 != s2 {
                return false
            }
        }

        return true
    }
}

// MARK: - Helper Function

private func createRouteInstance(_ routeType: any Route.Type, parameters: RouteParameters) throws -> any Route {
    try routeType.init(parameters: parameters)
}

// MARK: - Registry Validation Error

/// Errors that can occur during registry validation.
public enum RegistryValidationError: Error, CustomStringConvertible {

    /// A pattern has invalid syntax.
    case invalidPattern(String)

    /// Two patterns could match the same path.
    case ambiguousPatterns(String, String)

    /// A route name is duplicated.
    case duplicateName(String)

    public var description: String {
        switch self {
        case .invalidPattern(let pattern):
            return "Invalid pattern syntax: \(pattern)"
        case .ambiguousPatterns(let p1, let p2):
            return "Ambiguous patterns could conflict: '\(p1)' and '\(p2)'"
        case .duplicateName(let name):
            return "Duplicate route name: \(name)"
        }
    }
}

// MARK: - Route Group

/// A group of related routes with shared configuration.
///
/// ``RouteGroup`` provides a way to organize routes with common prefixes,
/// middleware, or authentication requirements.
///
/// ```swift
/// let apiGroup = RouteGroup(prefix: "/api/v1", requiresAuth: true)
/// apiGroup.add(UsersRoute.self)
/// apiGroup.add(PostsRoute.self)
/// registry.register(group: apiGroup)
/// ```
public struct RouteGroup {

    /// The common path prefix for routes in this group.
    public let prefix: String

    /// Default priority for routes in this group.
    public let defaultPriority: Int

    /// Whether routes in this group require authentication by default.
    public let requiresAuth: Bool

    /// Shared metadata for all routes in this group.
    public let metadata: [String: String]

    private var routeEntries: [RouteEntry] = []

    /// Creates a route group.
    ///
    /// - Parameters:
    ///   - prefix: The common path prefix.
    ///   - defaultPriority: Default priority. Defaults to `0`.
    ///   - requiresAuth: Whether auth is required. Defaults to `false`.
    ///   - metadata: Shared metadata. Defaults to empty.
    public init(
        prefix: String,
        defaultPriority: Int = 0,
        requiresAuth: Bool = false,
        metadata: [String: String] = [:]
    ) {
        self.prefix = prefix.hasPrefix("/") ? prefix : "/\(prefix)"
        self.defaultPriority = defaultPriority
        self.requiresAuth = requiresAuth
        self.metadata = metadata
    }

    /// Adds a route type to the group.
    ///
    /// - Parameters:
    ///   - routeType: The route type to add.
    ///   - priority: Optional priority override.
    ///   - requiresAuth: Optional auth requirement override.
    public mutating func add<R: Route>(
        _ routeType: R.Type,
        priority: Int? = nil,
        requiresAuth: Bool? = nil
    ) {
        let entry = RouteEntry(
            pattern: routeType.pattern,
            name: String(describing: routeType),
            priority: priority ?? defaultPriority,
            requiresAuth: requiresAuth ?? self.requiresAuth,
            factory: { params in try R(parameters: params) }
        )
        routeEntries.append(entry)
    }

    /// Returns all route definitions in this group with prefixed patterns.
    public func definitions() -> [RouteDefinition] {
        routeEntries.map { entry in
            let fullPattern = prefix + entry.pattern
            var mergedMetadata = metadata
            // Entry-specific metadata could override group metadata here

            return RouteDefinition(
                pattern: fullPattern,
                name: entry.name,
                priority: entry.priority,
                requiresAuth: entry.requiresAuth,
                metadata: mergedMetadata,
                factory: entry.factory
            )
        }
    }

    private struct RouteEntry {
        let pattern: String
        let name: String
        let priority: Int
        let requiresAuth: Bool
        let factory: @Sendable (RouteParameters) throws -> any Route
    }
}

// MARK: - Registry Extension

public extension RouteRegistry {

    /// Registers all routes from a group.
    ///
    /// - Parameter group: The route group to register.
    func register(group: RouteGroup) {
        for definition in group.definitions() {
            register(definition)
        }
    }
}
