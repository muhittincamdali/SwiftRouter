// AnalyticsMiddleware.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Analytics Tracker Protocol

/// A protocol for analytics event tracking integration.
///
/// Implement this protocol to connect your analytics service (Firebase,
/// Mixpanel, Amplitude, etc.) with the router's analytics middleware.
public protocol AnalyticsTracker: Sendable {

    /// Tracks a screen view event.
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen.
    ///   - parameters: Additional event parameters.
    func trackScreenView(screenName: String, parameters: [String: String]) async

    /// Tracks a navigation event.
    ///
    /// - Parameters:
    ///   - event: The event name.
    ///   - parameters: Event parameters.
    func trackEvent(event: String, parameters: [String: String]) async

    /// Tracks a navigation error.
    ///
    /// - Parameters:
    ///   - error: The error description.
    ///   - route: The route that failed.
    func trackError(error: String, route: String) async
}

// MARK: - Analytics Middleware

/// Middleware that tracks navigation events for analytics.
///
/// ``AnalyticsMiddleware`` automatically records screen views, navigation
/// timing, and error events through a pluggable ``AnalyticsTracker``.
///
/// ## Example
///
/// ```swift
/// let analytics = AnalyticsMiddleware(
///     tracker: FirebaseTracker(),
///     screenNameResolver: { route in
///         return String(describing: type(of: route))
///     }
/// )
/// router.use(analytics)
/// ```
public struct AnalyticsMiddleware: NavigationMiddleware {

    /// The middleware name.
    public let name = "AnalyticsMiddleware"

    /// The middleware priority. Analytics runs with low priority (after auth, etc.).
    public let priority: Int = -10

    /// Whether this middleware is enabled.
    public let isEnabled: Bool

    /// The analytics tracker implementation.
    private let tracker: any AnalyticsTracker

    /// A closure that resolves a route to a human-readable screen name.
    private let screenNameResolver: @Sendable (any Route) -> String

    /// Route patterns to exclude from tracking.
    private let excludedPatterns: [String]

    /// Whether to include route parameters in analytics events.
    private let includeParameters: Bool

    /// Whether to track navigation timing.
    private let trackTiming: Bool

    /// Creates an analytics middleware.
    ///
    /// - Parameters:
    ///   - tracker: The analytics tracker.
    ///   - screenNameResolver: Closure to derive screen names. Defaults to using the route pattern.
    ///   - excludedPatterns: Patterns to skip tracking. Defaults to empty.
    ///   - includeParameters: Include route params in events. Defaults to `false`.
    ///   - trackTiming: Track navigation timing. Defaults to `true`.
    ///   - isEnabled: Whether enabled. Defaults to `true`.
    public init(
        tracker: any AnalyticsTracker,
        screenNameResolver: (@Sendable (any Route) -> String)? = nil,
        excludedPatterns: [String] = [],
        includeParameters: Bool = false,
        trackTiming: Bool = true,
        isEnabled: Bool = true
    ) {
        self.tracker = tracker
        self.screenNameResolver = screenNameResolver ?? { route in
            type(of: route).pattern
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        }
        self.excludedPatterns = excludedPatterns
        self.includeParameters = includeParameters
        self.trackTiming = trackTiming
        self.isEnabled = isEnabled
    }

    public func handle(context: NavigationContext) async throws {
        let pattern = type(of: context.route).pattern
        guard !isExcluded(pattern: pattern) else { return }

        let screenName = screenNameResolver(context.route)
        var params: [String: String] = [
            "action": "\(context.action)",
            "animated": "\(context.isAnimated)",
            "pattern": pattern
        ]

        if includeParameters {
            for (key, value) in context.parameters.values {
                params["param_\(key)"] = value.stringValue
            }
        }

        await tracker.trackScreenView(screenName: screenName, parameters: params)
    }

    public func didComplete(context: NavigationContext) async {
        guard trackTiming else { return }
        let pattern = type(of: context.route).pattern
        guard !isExcluded(pattern: pattern) else { return }

        let duration = Date().timeIntervalSince(context.initiatedAt)
        await tracker.trackEvent(
            event: "navigation_completed",
            parameters: [
                "route": pattern,
                "duration_ms": "\(Int(duration * 1000))"
            ]
        )
    }

    public func didFail(context: NavigationContext, error: Error) async {
        let pattern = type(of: context.route).pattern
        await tracker.trackError(error: error.localizedDescription, route: pattern)
    }

    // MARK: - Private

    private func isExcluded(pattern: String) -> Bool {
        excludedPatterns.contains(pattern)
    }
}

// MARK: - Console Analytics Tracker

/// A simple analytics tracker that prints events to the console.
///
/// Useful for development and debugging. Replace with your actual
/// analytics service in production.
public struct ConsoleAnalyticsTracker: AnalyticsTracker {

    /// The log prefix.
    public let prefix: String

    /// Creates a console tracker.
    ///
    /// - Parameter prefix: The prefix for log lines. Defaults to `"[Analytics]"`.
    public init(prefix: String = "[Analytics]") {
        self.prefix = prefix
    }

    public func trackScreenView(screenName: String, parameters: [String: String]) async {
        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        print("\(prefix) Screen: \(screenName) [\(paramString)]")
    }

    public func trackEvent(event: String, parameters: [String: String]) async {
        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        print("\(prefix) Event: \(event) [\(paramString)]")
    }

    public func trackError(error: String, route: String) async {
        print("\(prefix) Error on \(route): \(error)")
    }
}
