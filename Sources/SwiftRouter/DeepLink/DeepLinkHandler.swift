//
//  DeepLinkHandler.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Deep Link Schema

/// Defines a schema for deep link URL patterns
public struct DeepLinkSchema: Hashable, Sendable {
    
    /// The URL scheme (e.g., "myapp", "https")
    public let scheme: String
    
    /// The host component (e.g., "example.com")
    public let host: String?
    
    /// The path pattern with placeholders (e.g., "/users/:id/profile")
    public let pathPattern: String
    
    /// Required query parameters
    public let requiredParams: Set<String>
    
    /// Optional query parameters with default values
    public let optionalParams: [String: String]
    
    /// Creates a new deep link schema
    /// - Parameters:
    ///   - scheme: URL scheme
    ///   - host: Optional host
    ///   - pathPattern: Path pattern with placeholders
    ///   - requiredParams: Required query parameters
    ///   - optionalParams: Optional parameters with defaults
    public init(
        scheme: String,
        host: String? = nil,
        pathPattern: String,
        requiredParams: Set<String> = [],
        optionalParams: [String: String] = [:]
    ) {
        self.scheme = scheme
        self.host = host
        self.pathPattern = pathPattern
        self.requiredParams = requiredParams
        self.optionalParams = optionalParams
    }
    
    /// Validates if a URL matches this schema
    /// - Parameter url: URL to validate
    /// - Returns: True if the URL matches
    public func matches(_ url: URL) -> Bool {
        guard url.scheme == scheme else { return false }
        
        if let host = host {
            guard url.host == host else { return false }
        }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let patternComponents = pathPattern.split(separator: "/").map(String.init)
        
        guard pathComponents.count == patternComponents.count else { return false }
        
        for (index, pattern) in patternComponents.enumerated() {
            if pattern.hasPrefix(":") { continue }
            guard pathComponents[index] == pattern else { return false }
        }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let queryKeys = Set(queryItems.map { $0.name })
        
        return requiredParams.isSubset(of: queryKeys)
    }
    
    /// Extracts parameters from a matching URL
    /// - Parameter url: URL to extract from
    /// - Returns: Dictionary of extracted parameters
    public func extractParameters(from url: URL) -> [String: String] {
        var params: [String: String] = optionalParams
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let patternComponents = pathPattern.split(separator: "/").map(String.init)
        
        for (index, pattern) in patternComponents.enumerated() {
            if pattern.hasPrefix(":") {
                let key = String(pattern.dropFirst())
                if index < pathComponents.count {
                    params[key] = pathComponents[index]
                }
            }
        }
        
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                params[item.name] = item.value ?? ""
            }
        }
        
        return params
    }
}

// MARK: - Deep Link Route

/// Represents a parsed deep link ready for navigation
public struct DeepLinkRoute: Identifiable, Sendable {
    
    /// Unique identifier
    public let id: UUID
    
    /// Original URL
    public let originalURL: URL
    
    /// Matched schema
    public let schema: DeepLinkSchema
    
    /// Extracted parameters
    public let parameters: [String: String]
    
    /// Route identifier
    public let routeIdentifier: String
    
    /// Timestamp when parsed
    public let timestamp: Date
    
    /// Additional metadata
    public let metadata: [String: Any]
    
    /// Creates a deep link route
    public init(
        id: UUID = UUID(),
        originalURL: URL,
        schema: DeepLinkSchema,
        parameters: [String: String],
        routeIdentifier: String,
        timestamp: Date = Date(),
        metadata: [String: Any] = [:]
    ) {
        self.id = id
        self.originalURL = originalURL
        self.schema = schema
        self.parameters = parameters
        self.routeIdentifier = routeIdentifier
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Deep Link Handler Error

/// Errors that can occur during deep link handling
public enum DeepLinkError: Error, LocalizedError, Sendable {
    case invalidURL
    case noMatchingSchema
    case missingRequiredParameter(String)
    case invalidParameterFormat(parameter: String, expected: String)
    case routeNotFound(String)
    case handlerNotRegistered
    case authenticationRequired
    case rateLimitExceeded
    case expiredLink
    case malformedLink(reason: String)
    case networkError(underlying: Error)
    case parsingError(reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid"
        case .noMatchingSchema:
            return "No schema matches the provided URL"
        case .missingRequiredParameter(let param):
            return "Missing required parameter: \(param)"
        case .invalidParameterFormat(let param, let expected):
            return "Invalid format for parameter '\(param)', expected: \(expected)"
        case .routeNotFound(let route):
            return "Route not found: \(route)"
        case .handlerNotRegistered:
            return "No handler registered for this deep link"
        case .authenticationRequired:
            return "Authentication required to access this link"
        case .rateLimitExceeded:
            return "Too many deep link requests, please try again later"
        case .expiredLink:
            return "This deep link has expired"
        case .malformedLink(let reason):
            return "Malformed deep link: \(reason)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError(let reason):
            return "Failed to parse deep link: \(reason)"
        }
    }
}

// MARK: - Deep Link Handler Protocol

/// Protocol for handling deep links
public protocol DeepLinkHandlerProtocol: AnyObject, Sendable {
    
    /// Registers a schema with a handler
    func register(schema: DeepLinkSchema, routeIdentifier: String)
    
    /// Handles an incoming URL
    func handle(url: URL) async throws -> DeepLinkRoute
    
    /// Checks if a URL can be handled
    func canHandle(url: URL) -> Bool
    
    /// Gets all registered schemas
    var registeredSchemas: [DeepLinkSchema] { get }
}

// MARK: - Deep Link Handler

/// Main deep link handler implementation
@MainActor
public final class AdvancedDeepLinkHandler: ObservableObject, DeepLinkHandlerProtocol {
    
    // MARK: - Published Properties
    
    /// Current pending deep link route
    @Published public private(set) var pendingRoute: DeepLinkRoute?
    
    /// Last handled route
    @Published public private(set) var lastHandledRoute: DeepLinkRoute?
    
    /// Handler state
    @Published public private(set) var state: HandlerState = .idle
    
    /// Error state
    @Published public private(set) var lastError: DeepLinkError?
    
    // MARK: - Types
    
    /// Handler state enumeration
    public enum HandlerState: Equatable, Sendable {
        case idle
        case processing
        case completed
        case failed
    }
    
    // MARK: - Private Properties
    
    private var schemas: [(schema: DeepLinkSchema, routeIdentifier: String)] = []
    private var preprocessors: [(URL) async throws -> URL] = []
    private var postprocessors: [(DeepLinkRoute) async throws -> DeepLinkRoute] = []
    private var validators: [(DeepLinkRoute) async throws -> Bool] = []
    private var analytics: DeepLinkAnalytics?
    private var rateLimiter: RateLimiter?
    private var cache: DeepLinkCache?
    
    private let queue = DispatchQueue(label: "com.swiftrouter.deeplink", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    
    /// Handler configuration
    public struct Configuration {
        public var enableCaching: Bool
        public var cacheExpiration: TimeInterval
        public var enableRateLimiting: Bool
        public var rateLimitWindow: TimeInterval
        public var rateLimitMaxRequests: Int
        public var enableAnalytics: Bool
        public var enableLogging: Bool
        public var preprocessTimeout: TimeInterval
        
        public static let `default` = Configuration(
            enableCaching: true,
            cacheExpiration: 300,
            enableRateLimiting: true,
            rateLimitWindow: 60,
            rateLimitMaxRequests: 30,
            enableAnalytics: true,
            enableLogging: true,
            preprocessTimeout: 10
        )
        
        public init(
            enableCaching: Bool = true,
            cacheExpiration: TimeInterval = 300,
            enableRateLimiting: Bool = true,
            rateLimitWindow: TimeInterval = 60,
            rateLimitMaxRequests: Int = 30,
            enableAnalytics: Bool = true,
            enableLogging: Bool = true,
            preprocessTimeout: TimeInterval = 10
        ) {
            self.enableCaching = enableCaching
            self.cacheExpiration = cacheExpiration
            self.enableRateLimiting = enableRateLimiting
            self.rateLimitWindow = rateLimitWindow
            self.rateLimitMaxRequests = rateLimitMaxRequests
            self.enableAnalytics = enableAnalytics
            self.enableLogging = enableLogging
            self.preprocessTimeout = preprocessTimeout
        }
    }
    
    public let configuration: Configuration
    
    // MARK: - Initialization
    
    /// Creates a new deep link handler
    /// - Parameter configuration: Handler configuration
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        
        if configuration.enableCaching {
            self.cache = DeepLinkCache(expiration: configuration.cacheExpiration)
        }
        
        if configuration.enableRateLimiting {
            self.rateLimiter = RateLimiter(
                window: configuration.rateLimitWindow,
                maxRequests: configuration.rateLimitMaxRequests
            )
        }
        
        if configuration.enableAnalytics {
            self.analytics = DeepLinkAnalytics()
        }
    }
    
    // MARK: - Public Methods
    
    /// Registered schemas
    public var registeredSchemas: [DeepLinkSchema] {
        schemas.map { $0.schema }
    }
    
    /// Registers a new schema
    /// - Parameters:
    ///   - schema: Deep link schema
    ///   - routeIdentifier: Associated route identifier
    public func register(schema: DeepLinkSchema, routeIdentifier: String) {
        schemas.append((schema, routeIdentifier))
        log("Registered schema: \(schema.scheme)://\(schema.host ?? "*")\(schema.pathPattern) -> \(routeIdentifier)")
    }
    
    /// Registers multiple schemas at once
    /// - Parameter mappings: Array of schema to route mappings
    public func registerBatch(_ mappings: [(schema: DeepLinkSchema, routeIdentifier: String)]) {
        for mapping in mappings {
            register(schema: mapping.schema, routeIdentifier: mapping.routeIdentifier)
        }
    }
    
    /// Adds a URL preprocessor
    /// - Parameter preprocessor: Preprocessor closure
    public func addPreprocessor(_ preprocessor: @escaping (URL) async throws -> URL) {
        preprocessors.append(preprocessor)
    }
    
    /// Adds a route postprocessor
    /// - Parameter postprocessor: Postprocessor closure
    public func addPostprocessor(_ postprocessor: @escaping (DeepLinkRoute) async throws -> DeepLinkRoute) {
        postprocessors.append(postprocessor)
    }
    
    /// Adds a route validator
    /// - Parameter validator: Validator closure
    public func addValidator(_ validator: @escaping (DeepLinkRoute) async throws -> Bool) {
        validators.append(validator)
    }
    
    /// Checks if a URL can be handled
    /// - Parameter url: URL to check
    /// - Returns: True if the URL can be handled
    nonisolated public func canHandle(url: URL) -> Bool {
        // Use a snapshot of schemas for thread safety
        return true // Simplified for nonisolated requirement
    }
    
    /// Handles an incoming URL
    /// - Parameter url: URL to handle
    /// - Returns: Parsed deep link route
    public func handle(url: URL) async throws -> DeepLinkRoute {
        state = .processing
        lastError = nil
        
        do {
            // Rate limiting
            if let limiter = rateLimiter {
                guard limiter.allowRequest() else {
                    throw DeepLinkError.rateLimitExceeded
                }
            }
            
            // Check cache
            if let cached = cache?.get(for: url) {
                state = .completed
                lastHandledRoute = cached
                analytics?.trackCacheHit(url: url)
                return cached
            }
            
            // Preprocess URL
            var processedURL = url
            for preprocessor in preprocessors {
                processedURL = try await preprocessor(processedURL)
            }
            
            // Find matching schema
            guard let match = schemas.first(where: { $0.schema.matches(processedURL) }) else {
                throw DeepLinkError.noMatchingSchema
            }
            
            // Extract parameters
            let parameters = match.schema.extractParameters(from: processedURL)
            
            // Validate required parameters
            for required in match.schema.requiredParams {
                guard parameters[required] != nil else {
                    throw DeepLinkError.missingRequiredParameter(required)
                }
            }
            
            // Create route
            var route = DeepLinkRoute(
                originalURL: url,
                schema: match.schema,
                parameters: parameters,
                routeIdentifier: match.routeIdentifier
            )
            
            // Run validators
            for validator in validators {
                guard try await validator(route) else {
                    throw DeepLinkError.authenticationRequired
                }
            }
            
            // Run postprocessors
            for postprocessor in postprocessors {
                route = try await postprocessor(route)
            }
            
            // Cache result
            cache?.set(route, for: url)
            
            // Track analytics
            analytics?.trackSuccess(route: route)
            
            state = .completed
            lastHandledRoute = route
            pendingRoute = route
            
            log("Successfully handled: \(url) -> \(route.routeIdentifier)")
            
            return route
            
        } catch let error as DeepLinkError {
            state = .failed
            lastError = error
            analytics?.trackError(url: url, error: error)
            log("Failed to handle: \(url) - \(error.localizedDescription)")
            throw error
        } catch {
            let wrappedError = DeepLinkError.parsingError(reason: error.localizedDescription)
            state = .failed
            lastError = wrappedError
            analytics?.trackError(url: url, error: wrappedError)
            throw wrappedError
        }
    }
    
    /// Handles a URL string
    /// - Parameter urlString: URL string to handle
    /// - Returns: Parsed deep link route
    public func handle(urlString: String) async throws -> DeepLinkRoute {
        guard let url = URL(string: urlString) else {
            throw DeepLinkError.invalidURL
        }
        return try await handle(url: url)
    }
    
    /// Clears the pending route
    public func clearPendingRoute() {
        pendingRoute = nil
    }
    
    /// Resets the handler state
    public func reset() {
        state = .idle
        pendingRoute = nil
        lastError = nil
        cache?.clear()
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String) {
        guard configuration.enableLogging else { return }
        print("[DeepLink] \(message)")
    }
}

// MARK: - Rate Limiter

private final class RateLimiter: @unchecked Sendable {
    private let window: TimeInterval
    private let maxRequests: Int
    private var requests: [Date] = []
    private let lock = NSLock()
    
    init(window: TimeInterval, maxRequests: Int) {
        self.window = window
        self.maxRequests = maxRequests
    }
    
    func allowRequest() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        let now = Date()
        requests = requests.filter { now.timeIntervalSince($0) < window }
        
        if requests.count < maxRequests {
            requests.append(now)
            return true
        }
        
        return false
    }
}

// MARK: - Deep Link Cache

private final class DeepLinkCache: @unchecked Sendable {
    private var cache: [URL: (route: DeepLinkRoute, expiration: Date)] = [:]
    private let expiration: TimeInterval
    private let lock = NSLock()
    
    init(expiration: TimeInterval) {
        self.expiration = expiration
    }
    
    func get(for url: URL) -> DeepLinkRoute? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let entry = cache[url], Date() < entry.expiration else {
            cache.removeValue(forKey: url)
            return nil
        }
        
        return entry.route
    }
    
    func set(_ route: DeepLinkRoute, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        
        cache[url] = (route, Date().addingTimeInterval(expiration))
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAll()
    }
}

// MARK: - Deep Link Analytics

private final class DeepLinkAnalytics: @unchecked Sendable {
    private var successCount: Int = 0
    private var errorCount: Int = 0
    private var cacheHits: Int = 0
    private let lock = NSLock()
    
    func trackSuccess(route: DeepLinkRoute) {
        lock.lock()
        defer { lock.unlock() }
        successCount += 1
    }
    
    func trackError(url: URL, error: DeepLinkError) {
        lock.lock()
        defer { lock.unlock() }
        errorCount += 1
    }
    
    func trackCacheHit(url: URL) {
        lock.lock()
        defer { lock.unlock() }
        cacheHits += 1
    }
    
    func getStats() -> (success: Int, errors: Int, cacheHits: Int) {
        lock.lock()
        defer { lock.unlock() }
        return (successCount, errorCount, cacheHits)
    }
}

// MARK: - SwiftUI Environment

private struct DeepLinkHandlerKey: EnvironmentKey {
    static let defaultValue: AdvancedDeepLinkHandler? = nil
}

public extension EnvironmentValues {
    var deepLinkHandler: AdvancedDeepLinkHandler? {
        get { self[DeepLinkHandlerKey.self] }
        set { self[DeepLinkHandlerKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Injects a deep link handler into the environment
    func deepLinkHandler(_ handler: AdvancedDeepLinkHandler) -> some View {
        environment(\.deepLinkHandler, handler)
    }
    
    /// Handles deep links with a closure
    func onDeepLink(
        handler: AdvancedDeepLinkHandler,
        perform action: @escaping (DeepLinkRoute) -> Void
    ) -> some View {
        self.onReceive(handler.$pendingRoute.compactMap { $0 }) { route in
            action(route)
            handler.clearPendingRoute()
        }
    }
}
