// CoreDeepLinkHandler.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Deep Link Result

/// The result of resolving a deep link URL to a route.
///
/// Contains the matched route, extracted parameters, and the original URL
/// for debugging and analytics purposes.
public struct DeepLinkResult: Sendable {

    /// The resolved route instance.
    public let route: any Route

    /// The parameters extracted from the URL.
    public let parameters: RouteParameters

    /// The original URL that was resolved.
    public let originalURL: URL

    /// The matched pattern string.
    public let matchedPattern: String

    /// Query parameters from the URL that weren't part of the path pattern.
    public let queryParameters: [String: String]

    /// The fragment identifier from the URL, if any.
    public let fragment: String?
}

// MARK: - Deep Link Handler Configuration

/// Configuration for the deep link handler.
public struct DeepLinkConfiguration: Sendable {

    /// The custom URL scheme (e.g., `"myapp"`).
    public let scheme: String

    /// The universal link host domains.
    public let universalLinkHosts: [String]

    /// Whether to perform case-insensitive path matching.
    public let caseInsensitive: Bool

    /// Whether to strip trailing slashes before matching.
    public let stripTrailingSlash: Bool

    /// A fallback route pattern when no match is found.
    public let fallbackPattern: String?

    /// Creates a deep link configuration.
    ///
    /// - Parameters:
    ///   - scheme: Custom URL scheme.
    ///   - universalLinkHosts: Universal link hosts.
    ///   - caseInsensitive: Case-insensitive matching. Defaults to `true`.
    ///   - stripTrailingSlash: Strip trailing slashes. Defaults to `true`.
    ///   - fallbackPattern: Fallback pattern. Defaults to `nil`.
    public init(
        scheme: String,
        universalLinkHosts: [String] = [],
        caseInsensitive: Bool = true,
        stripTrailingSlash: Bool = true,
        fallbackPattern: String? = nil
    ) {
        self.scheme = scheme
        self.universalLinkHosts = universalLinkHosts
        self.caseInsensitive = caseInsensitive
        self.stripTrailingSlash = stripTrailingSlash
        self.fallbackPattern = fallbackPattern
    }
}

// MARK: - Deep Link Handler

/// Handles deep link and universal link URL resolution.
///
/// ``DeepLinkHandler`` parses incoming URLs (both custom scheme and universal links),
/// matches them against registered route patterns, and produces ``DeepLinkResult``
/// instances that can be used for navigation.
///
/// ## Usage
///
/// ```swift
/// let handler = DeepLinkHandler(scheme: "myapp", universalLinkHosts: ["example.com"])
/// if let result = handler.resolve(url: incomingURL, registry: router.registry) {
///     try await router.navigate(to: result.route)
/// }
/// ```
public final class DeepLinkHandler: Sendable {

    // MARK: - Properties

    /// The configuration for this handler.
    public let configuration: DeepLinkConfiguration

    /// The custom URL scheme this handler responds to.
    public var scheme: String { configuration.scheme }

    /// The universal link hosts this handler responds to.
    public var universalLinkHosts: [String] { configuration.universalLinkHosts }

    /// Registered custom link transformers.
    private let transformers: [String: @Sendable (URL) -> URL?]

    // MARK: - Initialization

    /// Creates a deep link handler with the specified scheme and hosts.
    ///
    /// - Parameters:
    ///   - scheme: The custom URL scheme.
    ///   - universalLinkHosts: Universal link host domains.
    public convenience init(scheme: String, universalLinkHosts: [String] = []) {
        let config = DeepLinkConfiguration(
            scheme: scheme,
            universalLinkHosts: universalLinkHosts
        )
        self.init(configuration: config)
    }

    /// Creates a deep link handler with a full configuration.
    ///
    /// - Parameter configuration: The deep link configuration.
    public init(configuration: DeepLinkConfiguration) {
        self.configuration = configuration
        self.transformers = [:]
    }

    /// Creates a deep link handler with configuration and custom transformers.
    ///
    /// - Parameters:
    ///   - configuration: The deep link configuration.
    ///   - transformers: URL transformers keyed by identifier.
    public init(
        configuration: DeepLinkConfiguration,
        transformers: [String: @Sendable (URL) -> URL?]
    ) {
        self.configuration = configuration
        self.transformers = transformers
    }

    // MARK: - URL Validation

    /// Checks whether the handler can process the given URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if the URL matches the configured scheme or hosts.
    public func canHandle(url: URL) -> Bool {
        if url.scheme?.lowercased() == scheme.lowercased() {
            return true
        }

        if let host = url.host?.lowercased() {
            return universalLinkHosts.contains { $0.lowercased() == host }
        }

        return false
    }

    /// Determines the type of deep link for the given URL.
    ///
    /// - Parameter url: The URL to classify.
    /// - Returns: The ``CoreDeepLinkType`` classification.
    public func linkType(for url: URL) -> CoreDeepLinkType {
        if url.scheme?.lowercased() == scheme.lowercased() {
            return .customScheme
        }

        if let host = url.host?.lowercased(),
           universalLinkHosts.contains(where: { $0.lowercased() == host }) {
            return .universalLink
        }

        if url.scheme == "https" || url.scheme == "http" {
            return .webLink
        }

        return .unknown
    }

    // MARK: - Resolution

    /// Resolves a URL to a route using the given registry.
    ///
    /// - Parameters:
    ///   - url: The URL to resolve.
    ///   - registry: The route registry to search.
    /// - Returns: A ``DeepLinkResult`` if a matching route was found, otherwise `nil`.
    public func resolve(url: URL, registry: RouteRegistry) -> DeepLinkResult? {
        guard canHandle(url: url) else { return nil }

        var path = extractPath(from: url)

        // Apply transformers
        for (_, transformer) in transformers {
            if let transformed = transformer(url) {
                path = extractPath(from: transformed)
                break
            }
        }

        // Normalize path
        if configuration.stripTrailingSlash, path.hasSuffix("/"), path != "/" {
            path = String(path.dropLast())
        }

        if configuration.caseInsensitive {
            path = path.lowercased()
        }

        // Query parameters
        let queryParams = extractQueryParameters(from: url)

        // Try matching against registered routes
        let definitions = registry.allDefinitions
        let sortedDefinitions = definitions.sorted { $0.priority > $1.priority }

        for definition in sortedDefinitions {
            let patternToMatch = configuration.caseInsensitive
                ? definition.pattern.lowercased()
                : definition.pattern

            if let params = PathMatcher.shared.extractParameters(
                pattern: patternToMatch,
                path: path
            ) {
                // Merge query parameters
                var mergedValues = params.values
                for (key, value) in queryParams {
                    if mergedValues[key] == nil {
                        mergedValues[key] = .string(value)
                    }
                }

                let mergedParams = RouteParameters(mergedValues)

                do {
                    let route = try definition.createRoute(from: mergedParams)
                    return DeepLinkResult(
                        route: route,
                        parameters: mergedParams,
                        originalURL: url,
                        matchedPattern: definition.pattern,
                        queryParameters: queryParams,
                        fragment: url.fragment
                    )
                } catch {
                    continue
                }
            }
        }

        // Try fallback
        if let fallback = configuration.fallbackPattern,
           let fallbackDef = registry.definition(for: fallback) {
            let params = RouteParameters(["path": .string(path)])
            if let route = try? fallbackDef.createRoute(from: params) {
                return DeepLinkResult(
                    route: route,
                    parameters: params,
                    originalURL: url,
                    matchedPattern: fallback,
                    queryParameters: queryParams,
                    fragment: url.fragment
                )
            }
        }

        return nil
    }

    /// Resolves a URL string to a route.
    ///
    /// - Parameters:
    ///   - urlString: The URL string to resolve.
    ///   - registry: The route registry.
    /// - Returns: A ``DeepLinkResult`` if successful.
    public func resolve(urlString: String, registry: RouteRegistry) -> DeepLinkResult? {
        guard let url = URL(string: urlString) else { return nil }
        return resolve(url: url, registry: registry)
    }

    // MARK: - URL Construction

    /// Builds a deep link URL for the given route.
    ///
    /// - Parameters:
    ///   - route: The route to create a URL for.
    ///   - queryItems: Additional query parameters.
    /// - Returns: A URL representing the deep link, or `nil` if construction fails.
    public func buildURL(
        for route: any Route,
        queryItems: [URLQueryItem] = []
    ) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = ""

        var path = type(of: route).pattern
        for (key, value) in route.parameters.values {
            path = path.replacingOccurrences(of: ":\(key)", with: value.stringValue)
        }
        components.path = path

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url
    }

    /// Builds a universal link URL for the given route.
    ///
    /// - Parameters:
    ///   - route: The route.
    ///   - host: The host to use. Defaults to the first configured host.
    ///   - queryItems: Additional query parameters.
    /// - Returns: A universal link URL, or `nil`.
    public func buildUniversalLink(
        for route: any Route,
        host: String? = nil,
        queryItems: [URLQueryItem] = []
    ) -> URL? {
        guard let linkHost = host ?? universalLinkHosts.first else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = linkHost

        var path = type(of: route).pattern
        for (key, value) in route.parameters.values {
            path = path.replacingOccurrences(of: ":\(key)", with: value.stringValue)
        }
        components.path = path

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url
    }

    // MARK: - Private Helpers

    private func extractPath(from url: URL) -> String {
        if url.scheme?.lowercased() == scheme.lowercased() {
            // Custom scheme: myapp://host/path → /path
            let host = url.host ?? ""
            let path = url.path
            if host.isEmpty {
                return path.isEmpty ? "/" : path
            }
            return "/\(host)\(path)"
        }

        // Universal link: use the path directly
        return url.path.isEmpty ? "/" : url.path
    }

    private func extractQueryParameters(from url: URL) -> [String: String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }

        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value ?? ""
        }
        return params
    }
}

// MARK: - Core Deep Link Type

/// The classification of a deep link URL.
public enum CoreDeepLinkType: String, Sendable {

    /// A custom URL scheme link (e.g., `myapp://`).
    case customScheme

    /// A universal link (e.g., `https://example.com/path`).
    case universalLink

    /// A regular web link that may be interceptable.
    case webLink

    /// An unrecognized URL type.
    case unknown
}

// MARK: - Navigation Context

/// Context object passed through the middleware chain during navigation.
///
/// Contains all information about the current navigation request including
/// the target route, action, parameters, and mutable metadata that
/// middlewares can read from and write to.
public struct NavigationContext: Sendable {

    /// The target route being navigated to.
    public let route: any Route

    /// The navigation action being performed.
    public let action: NavigationAction

    /// The route parameters.
    public let parameters: RouteParameters

    /// Whether the navigation should be animated.
    public let isAnimated: Bool

    /// Mutable metadata that middlewares can use to pass data along the chain.
    public var metadata: [String: String]

    /// The timestamp when the navigation was initiated.
    public let initiatedAt: Date

    /// Creates a navigation context.
    ///
    /// - Parameters:
    ///   - route: The target route.
    ///   - action: The navigation action.
    ///   - parameters: Route parameters.
    ///   - isAnimated: Whether animated.
    ///   - metadata: Initial metadata. Defaults to empty.
    public init(
        route: any Route,
        action: NavigationAction,
        parameters: RouteParameters,
        isAnimated: Bool = true,
        metadata: [String: String] = [:]
    ) {
        self.route = route
        self.action = action
        self.parameters = parameters
        self.isAnimated = isAnimated
        self.metadata = metadata
        self.initiatedAt = Date()
    }
}
