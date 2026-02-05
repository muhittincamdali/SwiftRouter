// PathMatcher.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Path Matcher

/// A thread-safe utility for matching URL paths against route patterns.
///
/// ``PathMatcher`` handles pattern-based URL matching with support for:
/// - Static segments (`/users/settings`)
/// - Dynamic parameters (`:userId`)
/// - Wildcards (`*`)
/// - Optional segments (`?`)
///
/// ## Pattern Syntax
///
/// | Pattern | Example Match |
/// |---------|---------------|
/// | `/users` | `/users` |
/// | `/users/:id` | `/users/123` |
/// | `/files/*` | `/files/a/b/c` |
/// | `/items/:id?` | `/items` or `/items/42` |
public final class PathMatcher: Sendable {

    // MARK: - Singleton

    /// Shared instance for convenience.
    public static let shared = PathMatcher()

    // MARK: - Initialization

    /// Creates a new path matcher.
    public init() {}

    // MARK: - Matching

    /// Checks whether a path matches a pattern.
    ///
    /// - Parameters:
    ///   - pattern: The route pattern (e.g., `/users/:userId`).
    ///   - path: The actual URL path (e.g., `/users/42`).
    /// - Returns: `true` if the path matches the pattern.
    public func matches(pattern: String, path: String) -> Bool {
        extractParameters(pattern: pattern, path: path) != nil
    }

    /// Extracts parameters from a path using the given pattern.
    ///
    /// - Parameters:
    ///   - pattern: The route pattern.
    ///   - path: The URL path to extract from.
    /// - Returns: ``RouteParameters`` if matched, `nil` otherwise.
    public func extractParameters(pattern: String, path: String) -> RouteParameters? {
        let patternSegments = normalizeSegments(pattern)
        let pathSegments = normalizeSegments(path)

        // Handle wildcard pattern
        if pattern == "/*" || pattern == "*" {
            return RouteParameters(["path": .string(path)])
        }

        var parameters: [String: RouteParameterValue] = [:]
        var patternIndex = 0
        var pathIndex = 0

        while patternIndex < patternSegments.count {
            let patternSegment = patternSegments[patternIndex]

            // Wildcard - matches rest of path
            if patternSegment == "*" {
                let remaining = pathSegments[pathIndex...].joined(separator: "/")
                parameters["*"] = .string(remaining)
                return RouteParameters(parameters)
            }

            // Optional parameter
            if patternSegment.hasPrefix(":") && patternSegment.hasSuffix("?") {
                let paramName = String(patternSegment.dropFirst().dropLast())
                if pathIndex < pathSegments.count {
                    let value = pathSegments[pathIndex]
                    parameters[paramName] = RouteParameterValue.inferred(from: value)
                    pathIndex += 1
                }
                patternIndex += 1
                continue
            }

            // Required parameter
            if patternSegment.hasPrefix(":") {
                guard pathIndex < pathSegments.count else {
                    return nil // Missing required parameter
                }
                let paramName = String(patternSegment.dropFirst())
                let value = pathSegments[pathIndex]
                parameters[paramName] = RouteParameterValue.inferred(from: value)
                pathIndex += 1
                patternIndex += 1
                continue
            }

            // Static segment
            guard pathIndex < pathSegments.count else {
                return nil // Path too short
            }

            // Case-insensitive comparison for static segments
            guard patternSegment.lowercased() == pathSegments[pathIndex].lowercased() else {
                return nil // Static segment mismatch
            }

            pathIndex += 1
            patternIndex += 1
        }

        // Check for trailing path segments (no wildcard to consume them)
        if pathIndex < pathSegments.count {
            return nil // Path has extra segments
        }

        return RouteParameters(parameters)
    }

    /// Builds a path from a pattern and parameters.
    ///
    /// - Parameters:
    ///   - pattern: The route pattern.
    ///   - parameters: The parameters to substitute.
    /// - Returns: The constructed path, or `nil` if required parameters are missing.
    public func buildPath(pattern: String, parameters: RouteParameters) -> String? {
        var result = pattern

        // Extract parameter names from pattern
        let parameterNames = pattern
            .split(separator: "/")
            .filter { $0.hasPrefix(":") }
            .map { segment -> (name: String, isOptional: Bool) in
                var name = String(segment.dropFirst())
                let isOptional = name.hasSuffix("?")
                if isOptional {
                    name = String(name.dropLast())
                }
                return (name, isOptional)
            }

        for (name, isOptional) in parameterNames {
            let placeholder = isOptional ? ":\(name)?" : ":\(name)"
            if let value = parameters.value(for: name) {
                result = result.replacingOccurrences(of: placeholder, with: value.stringValue)
            } else if isOptional {
                // Remove optional segment entirely
                result = result.replacingOccurrences(of: "/\(placeholder)", with: "")
            } else {
                return nil // Missing required parameter
            }
        }

        return result
    }

    /// Calculates the specificity score of a pattern.
    ///
    /// Higher scores indicate more specific patterns. Used for route prioritization.
    ///
    /// - Parameter pattern: The route pattern.
    /// - Returns: The specificity score.
    public func specificity(of pattern: String) -> Int {
        let segments = normalizeSegments(pattern)
        var score = 0

        for segment in segments {
            if segment == "*" {
                score += 1
            } else if segment.hasPrefix(":") && segment.hasSuffix("?") {
                score += 5
            } else if segment.hasPrefix(":") {
                score += 10
            } else {
                score += 100 // Static segments are most specific
            }
        }

        return score
    }

    /// Validates a pattern syntax.
    ///
    /// - Parameter pattern: The pattern to validate.
    /// - Returns: `true` if the pattern is valid.
    public func isValidPattern(_ pattern: String) -> Bool {
        // Must start with /
        guard pattern.hasPrefix("/") || pattern == "*" else {
            return false
        }

        let segments = normalizeSegments(pattern)

        // Check for invalid parameter names
        for segment in segments {
            if segment.hasPrefix(":") {
                var paramName = String(segment.dropFirst())
                if paramName.hasSuffix("?") {
                    paramName = String(paramName.dropLast())
                }
                // Parameter name must be valid identifier
                guard paramName.range(of: "^[a-zA-Z_][a-zA-Z0-9_]*$", options: .regularExpression) != nil else {
                    return false
                }
            }
        }

        // Wildcard must be last
        if let wildcardIndex = segments.firstIndex(of: "*") {
            if wildcardIndex != segments.count - 1 {
                return false
            }
        }

        return true
    }

    // MARK: - Private

    private func normalizeSegments(_ path: String) -> [String] {
        path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
    }
}

// MARK: - Path Builder

/// A builder for constructing URL paths programmatically.
///
/// ```swift
/// let path = PathBuilder()
///     .append("users")
///     .append(userId)
///     .append("posts")
///     .build()  // "/users/123/posts"
/// ```
public struct PathBuilder {

    private var segments: [String] = []

    /// Creates a new path builder.
    public init() {}

    /// Appends a segment to the path.
    ///
    /// - Parameter segment: The segment to append.
    /// - Returns: The builder for chaining.
    public func append(_ segment: String) -> PathBuilder {
        var copy = self
        copy.segments.append(segment)
        return copy
    }

    /// Appends an integer segment.
    ///
    /// - Parameter value: The integer value.
    /// - Returns: The builder for chaining.
    public func append(_ value: Int) -> PathBuilder {
        append(String(value))
    }

    /// Appends a UUID segment.
    ///
    /// - Parameter uuid: The UUID value.
    /// - Returns: The builder for chaining.
    public func append(_ uuid: UUID) -> PathBuilder {
        append(uuid.uuidString)
    }

    /// Appends an optional segment if present.
    ///
    /// - Parameter segment: The optional segment.
    /// - Returns: The builder for chaining.
    public func appendIfPresent(_ segment: String?) -> PathBuilder {
        guard let segment = segment else { return self }
        return append(segment)
    }

    /// Builds the final path string.
    ///
    /// - Returns: The constructed path prefixed with `/`.
    public func build() -> String {
        "/" + segments.joined(separator: "/")
    }
}
