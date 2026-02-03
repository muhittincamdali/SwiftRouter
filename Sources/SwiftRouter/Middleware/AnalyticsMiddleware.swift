//
//  AnalyticsMiddleware.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine

// MARK: - Analytics Event

/// Represents an analytics event
public struct AnalyticsEvent: Identifiable, Sendable {
    
    /// Unique identifier
    public let id: UUID
    
    /// Event type
    public let type: EventType
    
    /// Event name
    public let name: String
    
    /// Event parameters
    public let parameters: [String: AnalyticsValue]
    
    /// Event timestamp
    public let timestamp: Date
    
    /// User ID (if available)
    public let userId: String?
    
    /// Session ID
    public let sessionId: String
    
    /// Event source
    public let source: EventSource
    
    /// Event type enumeration
    public enum EventType: String, Sendable {
        case screenView
        case navigation
        case action
        case error
        case timing
        case custom
        case userProperty
        case conversion
    }
    
    /// Event source enumeration
    public enum EventSource: String, Sendable {
        case router
        case deepLink
        case universalLink
        case notification
        case widget
        case shortcut
        case user
    }
    
    /// Creates an analytics event
    public init(
        id: UUID = UUID(),
        type: EventType,
        name: String,
        parameters: [String: AnalyticsValue] = [:],
        timestamp: Date = Date(),
        userId: String? = nil,
        sessionId: String,
        source: EventSource = .router
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
        self.userId = userId
        self.sessionId = sessionId
        self.source = source
    }
}

// MARK: - Analytics Value

/// Represents a value in analytics parameters
public enum AnalyticsValue: Sendable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnalyticsValue])
    case dictionary([String: AnalyticsValue])
    case null
    
    public var description: String {
        switch self {
        case .string(let value): return value
        case .int(let value): return "\(value)"
        case .double(let value): return "\(value)"
        case .bool(let value): return "\(value)"
        case .array(let values): return values.map { $0.description }.joined(separator: ", ")
        case .dictionary(let dict): return dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        case .null: return "null"
        }
    }
    
    public var stringValue: String { description }
}

// MARK: - Analytics Tracker Protocol

/// Protocol for analytics tracking implementations
public protocol AnalyticsTracker: Sendable {
    
    /// Tracks a screen view event
    func trackScreenView(screenName: String, parameters: [String: String]) async
    
    /// Tracks a general event
    func trackEvent(event: String, parameters: [String: String]) async
    
    /// Tracks an error
    func trackError(error: String, route: String) async
    
    /// Tracks a timing event
    func trackTiming(category: String, variable: String, value: TimeInterval, label: String?) async
    
    /// Sets a user property
    func setUserProperty(name: String, value: String?) async
    
    /// Sets the user ID
    func setUserId(_ userId: String?) async
    
    /// Flushes pending events
    func flush() async
}

// MARK: - Default Implementations

public extension AnalyticsTracker {
    func trackTiming(category: String, variable: String, value: TimeInterval, label: String?) async {}
    func setUserProperty(name: String, value: String?) async {}
    func setUserId(_ userId: String?) async {}
    func flush() async {}
}

// MARK: - Analytics Session

/// Manages an analytics session
public final class AnalyticsSession: @unchecked Sendable {
    
    /// Session ID
    public let id: String
    
    /// Session start time
    public let startTime: Date
    
    /// Last activity time
    public private(set) var lastActivityTime: Date
    
    /// Screen view count
    public private(set) var screenViewCount: Int = 0
    
    /// Event count
    public private(set) var eventCount: Int = 0
    
    /// Session duration
    public var duration: TimeInterval {
        lastActivityTime.timeIntervalSince(startTime)
    }
    
    /// Whether session is active
    public var isActive: Bool {
        Date().timeIntervalSince(lastActivityTime) < sessionTimeout
    }
    
    private let sessionTimeout: TimeInterval
    private let lock = NSLock()
    
    /// Creates a new session
    public init(sessionTimeout: TimeInterval = 1800) {
        self.id = UUID().uuidString
        self.startTime = Date()
        self.lastActivityTime = Date()
        self.sessionTimeout = sessionTimeout
    }
    
    /// Records activity
    func recordActivity() {
        lock.lock()
        defer { lock.unlock() }
        lastActivityTime = Date()
    }
    
    /// Records a screen view
    func recordScreenView() {
        lock.lock()
        defer { lock.unlock() }
        screenViewCount += 1
        lastActivityTime = Date()
    }
    
    /// Records an event
    func recordEvent() {
        lock.lock()
        defer { lock.unlock() }
        eventCount += 1
        lastActivityTime = Date()
    }
}

// MARK: - Analytics Configuration

/// Configuration for analytics middleware
public struct AnalyticsConfiguration: Sendable {
    
    /// Whether analytics is enabled
    public var isEnabled: Bool
    
    /// Whether to track screen views
    public var trackScreenViews: Bool
    
    /// Whether to track navigation timing
    public var trackTiming: Bool
    
    /// Whether to include route parameters
    public var includeParameters: Bool
    
    /// Session timeout in seconds
    public var sessionTimeout: TimeInterval
    
    /// Excluded route patterns
    public var excludedPatterns: Set<String>
    
    /// Sampling rate (0.0 - 1.0)
    public var samplingRate: Double
    
    /// Whether to batch events
    public var batchEvents: Bool
    
    /// Batch size
    public var batchSize: Int
    
    /// Batch flush interval
    public var batchFlushInterval: TimeInterval
    
    /// Whether to persist events offline
    public var persistOffline: Bool
    
    /// Maximum offline events
    public var maxOfflineEvents: Int
    
    /// Default configuration
    public static let `default` = AnalyticsConfiguration(
        isEnabled: true,
        trackScreenViews: true,
        trackTiming: true,
        includeParameters: false,
        sessionTimeout: 1800,
        excludedPatterns: [],
        samplingRate: 1.0,
        batchEvents: true,
        batchSize: 20,
        batchFlushInterval: 30,
        persistOffline: true,
        maxOfflineEvents: 1000
    )
    
    /// Creates configuration
    public init(
        isEnabled: Bool = true,
        trackScreenViews: Bool = true,
        trackTiming: Bool = true,
        includeParameters: Bool = false,
        sessionTimeout: TimeInterval = 1800,
        excludedPatterns: Set<String> = [],
        samplingRate: Double = 1.0,
        batchEvents: Bool = true,
        batchSize: Int = 20,
        batchFlushInterval: TimeInterval = 30,
        persistOffline: Bool = true,
        maxOfflineEvents: Int = 1000
    ) {
        self.isEnabled = isEnabled
        self.trackScreenViews = trackScreenViews
        self.trackTiming = trackTiming
        self.includeParameters = includeParameters
        self.sessionTimeout = sessionTimeout
        self.excludedPatterns = excludedPatterns
        self.samplingRate = max(0, min(1, samplingRate))
        self.batchEvents = batchEvents
        self.batchSize = batchSize
        self.batchFlushInterval = batchFlushInterval
        self.persistOffline = persistOffline
        self.maxOfflineEvents = maxOfflineEvents
    }
}

// MARK: - Analytics Middleware

/// Middleware for tracking navigation analytics
public struct AnalyticsMiddleware: NavigationMiddleware {
    
    /// Middleware name
    public let name = "AnalyticsMiddleware"
    
    /// Middleware priority (low priority, runs after auth)
    public let priority: Int = -10
    
    /// Whether enabled
    public var isEnabled: Bool { configuration.isEnabled }
    
    private let tracker: any AnalyticsTracker
    private let configuration: AnalyticsConfiguration
    private let screenNameResolver: @Sendable (any Route) -> String
    private let sessionManager: SessionManager
    private let eventBuffer: EventBuffer
    
    /// Creates analytics middleware
    /// - Parameters:
    ///   - tracker: Analytics tracker implementation
    ///   - configuration: Configuration
    ///   - screenNameResolver: Closure to resolve screen names
    public init(
        tracker: any AnalyticsTracker,
        configuration: AnalyticsConfiguration = .default,
        screenNameResolver: (@Sendable (any Route) -> String)? = nil
    ) {
        self.tracker = tracker
        self.configuration = configuration
        self.screenNameResolver = screenNameResolver ?? { route in
            type(of: route).pattern
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        }
        self.sessionManager = SessionManager(timeout: configuration.sessionTimeout)
        self.eventBuffer = EventBuffer(
            maxSize: configuration.batchSize,
            flushInterval: configuration.batchFlushInterval
        )
    }
    
    /// Handles navigation context
    public func handle(context: NavigationContext) async throws {
        guard configuration.isEnabled else { return }
        guard shouldSample() else { return }
        
        let pattern = type(of: context.route).pattern
        guard !isExcluded(pattern: pattern) else { return }
        
        sessionManager.recordActivity()
        
        if configuration.trackScreenViews {
            let screenName = screenNameResolver(context.route)
            var params = buildParameters(from: context)
            
            if configuration.batchEvents {
                eventBuffer.add(event: .screenView, name: screenName, parameters: params)
            } else {
                await tracker.trackScreenView(screenName: screenName, parameters: params)
            }
        }
    }
    
    /// Called when navigation completes
    public func didComplete(context: NavigationContext) async {
        guard configuration.isEnabled && configuration.trackTiming else { return }
        
        let pattern = type(of: context.route).pattern
        guard !isExcluded(pattern: pattern) else { return }
        
        let duration = Date().timeIntervalSince(context.initiatedAt)
        
        await tracker.trackTiming(
            category: "navigation",
            variable: "load_time",
            value: duration,
            label: pattern
        )
        
        await tracker.trackEvent(
            event: "navigation_completed",
            parameters: [
                "route": pattern,
                "duration_ms": "\(Int(duration * 1000))"
            ]
        )
    }
    
    /// Called when navigation fails
    public func didFail(context: NavigationContext, error: Error) async {
        guard configuration.isEnabled else { return }
        
        let pattern = type(of: context.route).pattern
        await tracker.trackError(error: error.localizedDescription, route: pattern)
    }
    
    /// Flushes buffered events
    public func flush() async {
        await eventBuffer.flush { events in
            for event in events {
                switch event.type {
                case .screenView:
                    await tracker.trackScreenView(
                        screenName: event.name,
                        parameters: event.parameters
                    )
                default:
                    await tracker.trackEvent(
                        event: event.name,
                        parameters: event.parameters
                    )
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldSample() -> Bool {
        guard configuration.samplingRate < 1.0 else { return true }
        return Double.random(in: 0...1) <= configuration.samplingRate
    }
    
    private func isExcluded(pattern: String) -> Bool {
        configuration.excludedPatterns.contains(pattern)
    }
    
    private func buildParameters(from context: NavigationContext) -> [String: String] {
        var params: [String: String] = [
            "action": "\(context.action)",
            "animated": "\(context.isAnimated)",
            "pattern": type(of: context.route).pattern,
            "session_id": sessionManager.currentSession.id
        ]
        
        if configuration.includeParameters {
            for (key, value) in context.parameters.values {
                params["param_\(key)"] = value.stringValue
            }
        }
        
        return params
    }
}

// MARK: - Session Manager

private final class SessionManager: @unchecked Sendable {
    private var _currentSession: AnalyticsSession
    private let timeout: TimeInterval
    private let lock = NSLock()
    
    var currentSession: AnalyticsSession {
        lock.lock()
        defer { lock.unlock() }
        
        if !_currentSession.isActive {
            _currentSession = AnalyticsSession(sessionTimeout: timeout)
        }
        return _currentSession
    }
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
        self._currentSession = AnalyticsSession(sessionTimeout: timeout)
    }
    
    func recordActivity() {
        lock.lock()
        defer { lock.unlock() }
        
        if !_currentSession.isActive {
            _currentSession = AnalyticsSession(sessionTimeout: timeout)
        }
        _currentSession.recordActivity()
    }
}

// MARK: - Event Buffer

private final class EventBuffer: @unchecked Sendable {
    private var events: [BufferedEvent] = []
    private let maxSize: Int
    private let flushInterval: TimeInterval
    private var lastFlush: Date = Date()
    private let lock = NSLock()
    
    struct BufferedEvent {
        let type: AnalyticsEvent.EventType
        let name: String
        let parameters: [String: String]
        let timestamp: Date
    }
    
    init(maxSize: Int, flushInterval: TimeInterval) {
        self.maxSize = maxSize
        self.flushInterval = flushInterval
    }
    
    func add(event: AnalyticsEvent.EventType, name: String, parameters: [String: String]) {
        lock.lock()
        defer { lock.unlock() }
        
        events.append(BufferedEvent(
            type: event,
            name: name,
            parameters: parameters,
            timestamp: Date()
        ))
    }
    
    func shouldFlush() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return events.count >= maxSize ||
            Date().timeIntervalSince(lastFlush) >= flushInterval
    }
    
    func flush(handler: ([BufferedEvent]) async -> Void) async {
        lock.lock()
        let eventsToFlush = events
        events = []
        lastFlush = Date()
        lock.unlock()
        
        await handler(eventsToFlush)
    }
}

// MARK: - Console Analytics Tracker

/// Debug analytics tracker that prints to console
public struct ConsoleAnalyticsTracker: AnalyticsTracker {
    
    /// Log prefix
    public let prefix: String
    
    /// Whether to include timestamps
    public let includeTimestamps: Bool
    
    /// Whether to use verbose output
    public let verbose: Bool
    
    /// Creates a console tracker
    public init(
        prefix: String = "[Analytics]",
        includeTimestamps: Bool = true,
        verbose: Bool = false
    ) {
        self.prefix = prefix
        self.includeTimestamps = includeTimestamps
        self.verbose = verbose
    }
    
    public func trackScreenView(screenName: String, parameters: [String: String]) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        let paramString = formatParameters(parameters)
        print("\(timestamp)\(prefix) Screen: \(screenName) \(paramString)")
    }
    
    public func trackEvent(event: String, parameters: [String: String]) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        let paramString = formatParameters(parameters)
        print("\(timestamp)\(prefix) Event: \(event) \(paramString)")
    }
    
    public func trackError(error: String, route: String) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        print("\(timestamp)\(prefix) ❌ Error on \(route): \(error)")
    }
    
    public func trackTiming(category: String, variable: String, value: TimeInterval, label: String?) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        let labelStr = label.map { " (\($0))" } ?? ""
        print("\(timestamp)\(prefix) ⏱ Timing: \(category)/\(variable) = \(Int(value * 1000))ms\(labelStr)")
    }
    
    public func setUserProperty(name: String, value: String?) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        let valueStr = value ?? "nil"
        print("\(timestamp)\(prefix) 👤 Property: \(name) = \(valueStr)")
    }
    
    public func setUserId(_ userId: String?) async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        let idStr = userId ?? "nil"
        print("\(timestamp)\(prefix) 🆔 User ID: \(idStr)")
    }
    
    public func flush() async {
        let timestamp = includeTimestamps ? "[\(formattedTime())] " : ""
        print("\(timestamp)\(prefix) 💾 Flushed events")
    }
    
    private func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
    
    private func formatParameters(_ params: [String: String]) -> String {
        guard !params.isEmpty else { return "" }
        if verbose {
            return "{\n" + params.map { "  \($0.key): \($0.value)" }.joined(separator: "\n") + "\n}"
        }
        return "[\(params.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))]"
    }
}

// MARK: - Composite Analytics Tracker

/// Tracker that forwards events to multiple trackers
public struct CompositeAnalyticsTracker: AnalyticsTracker {
    
    private let trackers: [any AnalyticsTracker]
    
    /// Creates a composite tracker
    /// - Parameter trackers: Trackers to forward events to
    public init(trackers: [any AnalyticsTracker]) {
        self.trackers = trackers
    }
    
    public func trackScreenView(screenName: String, parameters: [String: String]) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.trackScreenView(screenName: screenName, parameters: parameters)
                }
            }
        }
    }
    
    public func trackEvent(event: String, parameters: [String: String]) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.trackEvent(event: event, parameters: parameters)
                }
            }
        }
    }
    
    public func trackError(error: String, route: String) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.trackError(error: error, route: route)
                }
            }
        }
    }
    
    public func trackTiming(category: String, variable: String, value: TimeInterval, label: String?) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.trackTiming(category: category, variable: variable, value: value, label: label)
                }
            }
        }
    }
    
    public func setUserProperty(name: String, value: String?) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.setUserProperty(name: name, value: value)
                }
            }
        }
    }
    
    public func setUserId(_ userId: String?) async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.setUserId(userId)
                }
            }
        }
    }
    
    public func flush() async {
        await withTaskGroup(of: Void.self) { group in
            for tracker in trackers {
                group.addTask {
                    await tracker.flush()
                }
            }
        }
    }
}
