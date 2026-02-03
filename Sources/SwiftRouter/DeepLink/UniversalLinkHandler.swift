//
//  UniversalLinkHandler.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Universal Link Domain

/// Represents an associated domain configuration
public struct UniversalLinkDomain: Hashable, Sendable {
    
    /// Domain name (e.g., "example.com")
    public let domain: String
    
    /// Supported path prefixes
    public let pathPrefixes: [String]
    
    /// Whether to exclude certain paths
    public let excludedPaths: [String]
    
    /// Requires secure connection (HTTPS)
    public let requiresSecure: Bool
    
    /// Custom webcredentials support
    public let supportsWebCredentials: Bool
    
    /// App links support (Android interop)
    public let supportsAppLinks: Bool
    
    /// Creates a universal link domain configuration
    /// - Parameters:
    ///   - domain: Domain name
    ///   - pathPrefixes: Supported path prefixes
    ///   - excludedPaths: Paths to exclude
    ///   - requiresSecure: HTTPS requirement
    ///   - supportsWebCredentials: Webcredentials support
    ///   - supportsAppLinks: App links support
    public init(
        domain: String,
        pathPrefixes: [String] = ["/"],
        excludedPaths: [String] = [],
        requiresSecure: Bool = true,
        supportsWebCredentials: Bool = false,
        supportsAppLinks: Bool = false
    ) {
        self.domain = domain
        self.pathPrefixes = pathPrefixes
        self.excludedPaths = excludedPaths
        self.requiresSecure = requiresSecure
        self.supportsWebCredentials = supportsWebCredentials
        self.supportsAppLinks = supportsAppLinks
    }
    
    /// Validates if a URL belongs to this domain
    /// - Parameter url: URL to validate
    /// - Returns: True if URL belongs to this domain
    public func matches(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        
        // Check domain match
        guard host == domain || host.hasSuffix(".\(domain)") else {
            return false
        }
        
        // Check secure requirement
        if requiresSecure && url.scheme != "https" {
            return false
        }
        
        let path = url.path
        
        // Check excluded paths
        for excluded in excludedPaths {
            if path.hasPrefix(excluded) {
                return false
            }
        }
        
        // Check path prefixes
        if pathPrefixes.isEmpty { return true }
        
        return pathPrefixes.contains { path.hasPrefix($0) }
    }
}

// MARK: - Universal Link Route Pattern

/// Defines a route pattern for universal links
public struct UniversalLinkPattern: Identifiable, Hashable, Sendable {
    
    /// Unique identifier
    public let id: UUID
    
    /// Associated domain
    public let domain: UniversalLinkDomain
    
    /// Path pattern (e.g., "/products/:productId")
    public let pathPattern: String
    
    /// HTTP methods supported
    public let supportedMethods: Set<HTTPMethod>
    
    /// Required headers
    public let requiredHeaders: [String: String]
    
    /// Query parameter requirements
    public let queryRequirements: QueryRequirements
    
    /// Route priority (higher = more specific)
    public let priority: Int
    
    /// Target route identifier
    public let routeIdentifier: String
    
    /// HTTP Method enumeration
    public enum HTTPMethod: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    /// Query parameter requirements
    public struct QueryRequirements: Hashable, Sendable {
        public let required: Set<String>
        public let optional: Set<String>
        public let forbidden: Set<String>
        
        public init(
            required: Set<String> = [],
            optional: Set<String> = [],
            forbidden: Set<String> = []
        ) {
            self.required = required
            self.optional = optional
            self.forbidden = forbidden
        }
        
        public static let none = QueryRequirements()
    }
    
    /// Creates a universal link pattern
    public init(
        id: UUID = UUID(),
        domain: UniversalLinkDomain,
        pathPattern: String,
        supportedMethods: Set<HTTPMethod> = [.get],
        requiredHeaders: [String: String] = [:],
        queryRequirements: QueryRequirements = .none,
        priority: Int = 0,
        routeIdentifier: String
    ) {
        self.id = id
        self.domain = domain
        self.pathPattern = pathPattern
        self.supportedMethods = supportedMethods
        self.requiredHeaders = requiredHeaders
        self.queryRequirements = queryRequirements
        self.priority = priority
        self.routeIdentifier = routeIdentifier
    }
    
    /// Checks if a URL matches this pattern
    /// - Parameter url: URL to check
    /// - Returns: True if URL matches
    public func matches(_ url: URL) -> Bool {
        guard domain.matches(url) else { return false }
        return matchesPath(url.path)
    }
    
    /// Extracts path parameters from URL
    /// - Parameter url: URL to extract from
    /// - Returns: Dictionary of parameters
    public func extractParameters(from url: URL) -> [String: String] {
        var parameters: [String: String] = [:]
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let patternComponents = pathPattern.split(separator: "/").map(String.init)
        
        for (index, component) in patternComponents.enumerated() {
            if component.hasPrefix(":") {
                let paramName = String(component.dropFirst())
                if index < pathComponents.count {
                    parameters[paramName] = pathComponents[index]
                }
            }
        }
        
        // Extract query parameters
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value ?? ""
            }
        }
        
        return parameters
    }
    
    private func matchesPath(_ path: String) -> Bool {
        let pathComponents = path.split(separator: "/").map(String.init)
        let patternComponents = pathPattern.split(separator: "/").map(String.init)
        
        guard pathComponents.count == patternComponents.count else { return false }
        
        for (index, component) in patternComponents.enumerated() {
            if component.hasPrefix(":") { continue }
            guard pathComponents[index] == component else { return false }
        }
        
        return true
    }
}

// MARK: - Universal Link Result

/// Result of handling a universal link
public struct UniversalLinkResult: Identifiable, Sendable {
    
    /// Unique identifier
    public let id: UUID
    
    /// Original URL
    public let originalURL: URL
    
    /// Matched pattern
    public let pattern: UniversalLinkPattern
    
    /// Extracted parameters
    public let parameters: [String: String]
    
    /// Target route
    public let routeIdentifier: String
    
    /// Processing timestamp
    public let timestamp: Date
    
    /// Source of the link
    public let source: LinkSource
    
    /// User activity (if applicable)
    public let userActivity: NSUserActivity?
    
    /// Link source enumeration
    public enum LinkSource: String, Sendable {
        case safari
        case mail
        case messages
        case thirdPartyApp
        case spotlight
        case siri
        case handoff
        case widget
        case notification
        case unknown
    }
    
    /// Creates a universal link result
    public init(
        id: UUID = UUID(),
        originalURL: URL,
        pattern: UniversalLinkPattern,
        parameters: [String: String],
        routeIdentifier: String,
        timestamp: Date = Date(),
        source: LinkSource = .unknown,
        userActivity: NSUserActivity? = nil
    ) {
        self.id = id
        self.originalURL = originalURL
        self.pattern = pattern
        self.parameters = parameters
        self.routeIdentifier = routeIdentifier
        self.timestamp = timestamp
        self.source = source
        self.userActivity = userActivity
    }
}

// MARK: - Universal Link Error

/// Errors during universal link handling
public enum UniversalLinkError: Error, LocalizedError, Sendable {
    case invalidURL
    case domainNotConfigured(String)
    case pathNotMatched(String)
    case missingRequiredParameter(String)
    case forbiddenParameter(String)
    case authenticationRequired
    case unsupportedMethod
    case validationFailed(reason: String)
    case handlerNotFound
    case configurationError(String)
    case networkError(String)
    case timeout
    case rateLimited
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The universal link URL is invalid"
        case .domainNotConfigured(let domain):
            return "Domain not configured: \(domain)"
        case .pathNotMatched(let path):
            return "No pattern matches path: \(path)"
        case .missingRequiredParameter(let param):
            return "Missing required parameter: \(param)"
        case .forbiddenParameter(let param):
            return "Forbidden parameter found: \(param)"
        case .authenticationRequired:
            return "Authentication is required for this link"
        case .unsupportedMethod:
            return "HTTP method not supported for this link"
        case .validationFailed(let reason):
            return "Validation failed: \(reason)"
        case .handlerNotFound:
            return "No handler registered for this link"
        case .configurationError(let msg):
            return "Configuration error: \(msg)"
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .timeout:
            return "Request timed out"
        case .rateLimited:
            return "Rate limit exceeded"
        }
    }
}

// MARK: - Universal Link Handler

/// Handles universal links (AASA-based deep links)
@MainActor
public final class UniversalLinkHandler: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current pending result
    @Published public private(set) var pendingResult: UniversalLinkResult?
    
    /// Last handled result
    @Published public private(set) var lastResult: UniversalLinkResult?
    
    /// Handler state
    @Published public private(set) var state: HandlerState = .idle
    
    /// Last error
    @Published public private(set) var lastError: UniversalLinkError?
    
    /// Handler state
    public enum HandlerState: Equatable, Sendable {
        case idle
        case processing
        case completed
        case failed
    }
    
    // MARK: - Private Properties
    
    private var domains: [UniversalLinkDomain] = []
    private var patterns: [UniversalLinkPattern] = []
    private var validators: [(UniversalLinkResult) async throws -> Bool] = []
    private var interceptors: [(URL) async throws -> URL?] = []
    private var analytics: UniversalLinkAnalytics?
    private var rateLimiter: UniversalLinkRateLimiter?
    private let configuration: Configuration
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    
    /// Handler configuration
    public struct Configuration {
        public var enableAnalytics: Bool
        public var enableRateLimiting: Bool
        public var rateLimitWindow: TimeInterval
        public var rateLimitMaxRequests: Int
        public var enableLogging: Bool
        public var validationTimeout: TimeInterval
        public var allowInsecureLinks: Bool
        
        public static let `default` = Configuration(
            enableAnalytics: true,
            enableRateLimiting: true,
            rateLimitWindow: 60,
            rateLimitMaxRequests: 50,
            enableLogging: true,
            validationTimeout: 10,
            allowInsecureLinks: false
        )
        
        public init(
            enableAnalytics: Bool = true,
            enableRateLimiting: Bool = true,
            rateLimitWindow: TimeInterval = 60,
            rateLimitMaxRequests: Int = 50,
            enableLogging: Bool = true,
            validationTimeout: TimeInterval = 10,
            allowInsecureLinks: Bool = false
        ) {
            self.enableAnalytics = enableAnalytics
            self.enableRateLimiting = enableRateLimiting
            self.rateLimitWindow = rateLimitWindow
            self.rateLimitMaxRequests = rateLimitMaxRequests
            self.enableLogging = enableLogging
            self.validationTimeout = validationTimeout
            self.allowInsecureLinks = allowInsecureLinks
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a universal link handler
    /// - Parameter configuration: Handler configuration
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        
        if configuration.enableAnalytics {
            analytics = UniversalLinkAnalytics()
        }
        
        if configuration.enableRateLimiting {
            rateLimiter = UniversalLinkRateLimiter(
                window: configuration.rateLimitWindow,
                maxRequests: configuration.rateLimitMaxRequests
            )
        }
    }
    
    // MARK: - Domain Registration
    
    /// Registers a domain for universal link handling
    /// - Parameter domain: Domain configuration
    public func registerDomain(_ domain: UniversalLinkDomain) {
        domains.append(domain)
        log("Registered domain: \(domain.domain)")
    }
    
    /// Registers multiple domains
    /// - Parameter domains: Array of domain configurations
    public func registerDomains(_ domains: [UniversalLinkDomain]) {
        for domain in domains {
            registerDomain(domain)
        }
    }
    
    /// Checks if a domain is registered
    /// - Parameter domain: Domain to check
    /// - Returns: True if registered
    public func isDomainRegistered(_ domain: String) -> Bool {
        domains.contains { $0.domain == domain }
    }
    
    // MARK: - Pattern Registration
    
    /// Registers a URL pattern
    /// - Parameter pattern: Pattern to register
    public func registerPattern(_ pattern: UniversalLinkPattern) {
        patterns.append(pattern)
        patterns.sort { $0.priority > $1.priority }
        log("Registered pattern: \(pattern.pathPattern) -> \(pattern.routeIdentifier)")
    }
    
    /// Registers multiple patterns
    /// - Parameter patterns: Patterns to register
    public func registerPatterns(_ patterns: [UniversalLinkPattern]) {
        for pattern in patterns {
            registerPattern(pattern)
        }
    }
    
    /// Unregisters a pattern
    /// - Parameter pattern: Pattern to remove
    public func unregisterPattern(_ pattern: UniversalLinkPattern) {
        patterns.removeAll { $0.id == pattern.id }
    }
    
    // MARK: - Validators and Interceptors
    
    /// Adds a result validator
    /// - Parameter validator: Validator closure
    public func addValidator(_ validator: @escaping (UniversalLinkResult) async throws -> Bool) {
        validators.append(validator)
    }
    
    /// Adds a URL interceptor
    /// - Parameter interceptor: Interceptor closure
    public func addInterceptor(_ interceptor: @escaping (URL) async throws -> URL?) {
        interceptors.append(interceptor)
    }
    
    // MARK: - URL Handling
    
    /// Checks if a URL can be handled
    /// - Parameter url: URL to check
    /// - Returns: True if the URL can be handled
    public func canHandle(url: URL) -> Bool {
        guard let host = url.host else { return false }
        
        // Check if domain is registered
        guard domains.contains(where: { $0.matches(url) }) else {
            return false
        }
        
        // Check if any pattern matches
        return patterns.contains { $0.matches(url) }
    }
    
    /// Handles a universal link URL
    /// - Parameters:
    ///   - url: URL to handle
    ///   - source: Source of the link
    ///   - userActivity: Associated user activity
    /// - Returns: Universal link result
    public func handle(
        url: URL,
        source: UniversalLinkResult.LinkSource = .unknown,
        userActivity: NSUserActivity? = nil
    ) async throws -> UniversalLinkResult {
        state = .processing
        lastError = nil
        
        log("Handling universal link: \(url)")
        
        do {
            // Rate limiting
            if let limiter = rateLimiter {
                guard limiter.allowRequest() else {
                    throw UniversalLinkError.rateLimited
                }
            }
            
            // Run interceptors
            var processedURL = url
            for interceptor in interceptors {
                if let newURL = try await interceptor(processedURL) {
                    processedURL = newURL
                }
            }
            
            // Validate URL
            guard let host = processedURL.host else {
                throw UniversalLinkError.invalidURL
            }
            
            // Check domain configuration
            guard domains.contains(where: { $0.matches(processedURL) }) else {
                throw UniversalLinkError.domainNotConfigured(host)
            }
            
            // Check security
            if !configuration.allowInsecureLinks && processedURL.scheme != "https" {
                throw UniversalLinkError.validationFailed(reason: "Insecure link not allowed")
            }
            
            // Find matching pattern
            guard let pattern = patterns.first(where: { $0.matches(processedURL) }) else {
                throw UniversalLinkError.pathNotMatched(processedURL.path)
            }
            
            // Extract parameters
            let parameters = pattern.extractParameters(from: processedURL)
            
            // Validate required parameters
            for required in pattern.queryRequirements.required {
                guard parameters[required] != nil else {
                    throw UniversalLinkError.missingRequiredParameter(required)
                }
            }
            
            // Check forbidden parameters
            for forbidden in pattern.queryRequirements.forbidden {
                if parameters[forbidden] != nil {
                    throw UniversalLinkError.forbiddenParameter(forbidden)
                }
            }
            
            // Create result
            var result = UniversalLinkResult(
                originalURL: url,
                pattern: pattern,
                parameters: parameters,
                routeIdentifier: pattern.routeIdentifier,
                source: source,
                userActivity: userActivity
            )
            
            // Run validators
            for validator in validators {
                guard try await validator(result) else {
                    throw UniversalLinkError.validationFailed(reason: "Custom validation failed")
                }
            }
            
            // Track analytics
            analytics?.trackSuccess(result: result)
            
            state = .completed
            lastResult = result
            pendingResult = result
            
            log("Successfully handled: \(url) -> \(result.routeIdentifier)")
            
            return result
            
        } catch let error as UniversalLinkError {
            state = .failed
            lastError = error
            analytics?.trackError(url: url, error: error)
            log("Failed to handle: \(url) - \(error.localizedDescription)")
            throw error
        } catch {
            let wrapped = UniversalLinkError.validationFailed(reason: error.localizedDescription)
            state = .failed
            lastError = wrapped
            throw wrapped
        }
    }
    
    /// Handles a user activity containing a universal link
    /// - Parameter userActivity: User activity to handle
    /// - Returns: Universal link result
    public func handle(userActivity: NSUserActivity) async throws -> UniversalLinkResult {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            throw UniversalLinkError.invalidURL
        }
        
        guard let url = userActivity.webpageURL else {
            throw UniversalLinkError.invalidURL
        }
        
        let source = determineSource(from: userActivity)
        return try await handle(url: url, source: source, userActivity: userActivity)
    }
    
    /// Clears the pending result
    public func clearPendingResult() {
        pendingResult = nil
    }
    
    /// Resets handler state
    public func reset() {
        state = .idle
        pendingResult = nil
        lastError = nil
    }
    
    // MARK: - Private Methods
    
    private func determineSource(from activity: NSUserActivity) -> UniversalLinkResult.LinkSource {
        if activity.activityType == NSUserActivityTypeBrowsingWeb {
            return .safari
        }
        
        if let referrerURL = activity.referrerURL {
            if referrerURL.scheme == "message" {
                return .messages
            }
            if referrerURL.scheme == "mailto" {
                return .mail
            }
        }
        
        return .unknown
    }
    
    private func log(_ message: String) {
        guard configuration.enableLogging else { return }
        print("[UniversalLink] \(message)")
    }
}

// MARK: - Rate Limiter

private final class UniversalLinkRateLimiter: @unchecked Sendable {
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

// MARK: - Analytics

private final class UniversalLinkAnalytics: @unchecked Sendable {
    private var successByDomain: [String: Int] = [:]
    private var errorsByType: [String: Int] = [:]
    private var sourceDistribution: [String: Int] = [:]
    private let lock = NSLock()
    
    func trackSuccess(result: UniversalLinkResult) {
        lock.lock()
        defer { lock.unlock() }
        
        let domain = result.pattern.domain.domain
        successByDomain[domain, default: 0] += 1
        sourceDistribution[result.source.rawValue, default: 0] += 1
    }
    
    func trackError(url: URL, error: UniversalLinkError) {
        lock.lock()
        defer { lock.unlock() }
        
        let errorType = String(describing: type(of: error))
        errorsByType[errorType, default: 0] += 1
    }
    
    func getStatistics() -> UniversalLinkStatistics {
        lock.lock()
        defer { lock.unlock() }
        
        return UniversalLinkStatistics(
            successByDomain: successByDomain,
            errorsByType: errorsByType,
            sourceDistribution: sourceDistribution
        )
    }
}

/// Universal link statistics
public struct UniversalLinkStatistics: Sendable {
    public let successByDomain: [String: Int]
    public let errorsByType: [String: Int]
    public let sourceDistribution: [String: Int]
    
    public var totalSuccess: Int {
        successByDomain.values.reduce(0, +)
    }
    
    public var totalErrors: Int {
        errorsByType.values.reduce(0, +)
    }
}

// MARK: - SwiftUI Integration

private struct UniversalLinkHandlerKey: EnvironmentKey {
    static let defaultValue: UniversalLinkHandler? = nil
}

public extension EnvironmentValues {
    var universalLinkHandler: UniversalLinkHandler? {
        get { self[UniversalLinkHandlerKey.self] }
        set { self[UniversalLinkHandlerKey.self] = newValue }
    }
}

public extension View {
    /// Injects a universal link handler into the environment
    func universalLinkHandler(_ handler: UniversalLinkHandler) -> some View {
        environment(\.universalLinkHandler, handler)
    }
    
    /// Handles universal links with a closure
    func onUniversalLink(
        handler: UniversalLinkHandler,
        perform action: @escaping (UniversalLinkResult) -> Void
    ) -> some View {
        self.onReceive(handler.$pendingResult.compactMap { $0 }) { result in
            action(result)
            handler.clearPendingResult()
        }
    }
}
