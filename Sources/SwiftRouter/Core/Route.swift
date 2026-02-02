// Route.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Route Protocol

/// A protocol that defines a navigable route within the application.
///
/// Conform to ``Route`` to create type-safe destinations that the ``Router``
/// can resolve and navigate to. Each route must define a unique ``pattern``
/// used for URL matching and deep link resolution.
///
/// ## Example
///
/// ```swift
/// struct ProfileRoute: Route {
///     static let pattern = "/profile/:userId"
///     let userId: String
///
///     var parameters: RouteParameters {
///         RouteParameters(["userId": .string(userId)])
///     }
///
///     init(parameters: RouteParameters) throws {
///         guard let userId = parameters.string(for: "userId") else {
///             throw RouteError.missingParameter("userId")
///         }
///         self.userId = userId
///     }
/// }
/// ```
public protocol Route: Sendable {

    /// The URL pattern for this route, using `:paramName` for path parameters.
    ///
    /// Examples:
    /// - `"/home"` — a static route
    /// - `"/profile/:userId"` — a parameterized route
    /// - `"/settings/:section/:item"` — multi-parameter route
    static var pattern: String { get }

    /// The extracted parameters from this route instance.
    var parameters: RouteParameters { get }

    /// Creates a route from the given parameters.
    ///
    /// - Parameter parameters: The route parameters extracted from a URL or supplied programmatically.
    /// - Throws: ``RouteError`` if required parameters are missing or invalid.
    init(parameters: RouteParameters) throws
}

/// Convenience extensions on ``Route``.
public extension Route {

    /// The pattern string for this route instance.
    var pattern: String { Self.pattern }

    /// The path segments of the pattern, split by `/`.
    var pathSegments: [String] {
        Self.pattern
            .split(separator: "/")
            .map(String.init)
    }

    /// The parameter names declared in the pattern.
    static var parameterNames: [String] {
        pattern
            .split(separator: "/")
            .filter { $0.hasPrefix(":") }
            .map { String($0.dropFirst()) }
    }

    /// Whether this route's pattern matches the given path string.
    ///
    /// - Parameter path: The path to test against.
    /// - Returns: `true` if the path matches this route's pattern.
    static func matches(path: String) -> Bool {
        PathMatcher.shared.matches(pattern: pattern, path: path)
    }

    /// Extracts parameters from a path using this route's pattern.
    ///
    /// - Parameter path: The URL path to extract parameters from.
    /// - Returns: The extracted ``RouteParameters``, or `nil` if the path doesn't match.
    static func extractParameters(from path: String) -> RouteParameters? {
        PathMatcher.shared.extractParameters(pattern: pattern, path: path)
    }
}

// MARK: - Route Error

/// Errors that can occur during route initialization or parameter extraction.
public enum RouteError: Error, Sendable, CustomStringConvertible {

    /// A required parameter was not provided.
    case missingParameter(String)

    /// A parameter value could not be converted to the expected type.
    case invalidParameterType(name: String, expected: String)

    /// The route pattern is malformed.
    case invalidPattern(String)

    /// A custom validation error.
    case validationFailed(String)

    public var description: String {
        switch self {
        case .missingParameter(let name):
            return "Missing required parameter: \(name)"
        case .invalidParameterType(let name, let expected):
            return "Parameter '\(name)' expected type \(expected)"
        case .invalidPattern(let pattern):
            return "Invalid route pattern: \(pattern)"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        }
    }
}

// MARK: - Route Definition

/// A concrete definition that pairs a route type with its metadata.
///
/// ``RouteDefinition`` is used internally by the ``RouteRegistry`` to store
/// registered routes alongside their factory closures and metadata.
public struct RouteDefinition: Sendable {

    /// The route pattern string.
    public let pattern: String

    /// A human-readable name for the route.
    public let name: String

    /// The parameter names extracted from the pattern.
    public let parameterNames: [String]

    /// The number of static (non-parameter) segments in the pattern.
    public let staticSegmentCount: Int

    /// Priority for route matching when multiple patterns could match.
    /// Higher values indicate higher priority.
    public let priority: Int

    /// Whether this route requires authentication.
    public let requiresAuth: Bool

    /// Optional metadata associated with this route.
    public let metadata: [String: String]

    /// Factory closure that creates a route instance from parameters.
    let factory: @Sendable (RouteParameters) throws -> any Route

    /// Creates a new route definition.
    ///
    /// - Parameters:
    ///   - pattern: The URL pattern.
    ///   - name: A human-readable name.
    ///   - priority: Match priority. Defaults to `0`.
    ///   - requiresAuth: Whether auth is required. Defaults to `false`.
    ///   - metadata: Additional metadata. Defaults to empty.
    ///   - factory: Factory closure to create route instances.
    public init(
        pattern: String,
        name: String,
        priority: Int = 0,
        requiresAuth: Bool = false,
        metadata: [String: String] = [:],
        factory: @escaping @Sendable (RouteParameters) throws -> any Route
    ) {
        self.pattern = pattern
        self.name = name
        self.priority = priority
        self.requiresAuth = requiresAuth
        self.metadata = metadata
        self.factory = factory

        let segments = pattern.split(separator: "/").map(String.init)
        self.parameterNames = segments.filter { $0.hasPrefix(":") }.map { String($0.dropFirst()) }
        self.staticSegmentCount = segments.filter { !$0.hasPrefix(":") }.count
    }

    /// Creates a route instance from the given parameters.
    ///
    /// - Parameter parameters: The route parameters.
    /// - Returns: A new route instance.
    /// - Throws: ``RouteError`` if creation fails.
    public func createRoute(from parameters: RouteParameters) throws -> any Route {
        try factory(parameters)
    }
}

// MARK: - Common Routes

/// A simple route that wraps a raw path string with no typed parameters.
///
/// Use ``RawRoute`` when you need to navigate to a path that doesn't have
/// a dedicated ``Route`` type registered.
public struct RawRoute: Route {

    public static let pattern = "/*"

    /// The raw path string.
    public let path: String

    public var parameters: RouteParameters {
        RouteParameters(["path": .string(path)])
    }

    /// Creates a raw route with the given path.
    ///
    /// - Parameter path: The navigation path.
    public init(path: String) {
        self.path = path
    }

    public init(parameters: RouteParameters) throws {
        guard let path = parameters.string(for: "path") else {
            throw RouteError.missingParameter("path")
        }
        self.path = path
    }
}

/// A tab-based route for switching between top-level tabs.
public struct TabRoute: Route {

    public static let pattern = "/tab/:index"

    /// The tab index to switch to.
    public let index: Int

    /// Optional tab identifier string.
    public let identifier: String?

    public var parameters: RouteParameters {
        var params: [String: RouteParameterValue] = ["index": .integer(index)]
        if let identifier {
            params["identifier"] = .string(identifier)
        }
        return RouteParameters(params)
    }

    /// Creates a tab route.
    ///
    /// - Parameters:
    ///   - index: The tab index.
    ///   - identifier: Optional tab identifier.
    public init(index: Int, identifier: String? = nil) {
        self.index = index
        self.identifier = identifier
    }

    public init(parameters: RouteParameters) throws {
        guard let index = parameters.integer(for: "index") else {
            throw RouteError.missingParameter("index")
        }
        self.index = index
        self.identifier = parameters.string(for: "identifier")
    }
}
