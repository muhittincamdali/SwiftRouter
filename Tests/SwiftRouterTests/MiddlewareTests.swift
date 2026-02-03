//
//  MiddlewareTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

// MARK: - Analytics Middleware Tests

final class AnalyticsMiddlewareTests: XCTestCase {
    
    // MARK: - Analytics Event Tests
    
    func testAnalyticsEventCreation() {
        let event = AnalyticsEvent(
            type: .screenView,
            name: "HomeScreen",
            parameters: ["key": .string("value")],
            sessionId: "test-session"
        )
        
        XCTAssertNotNil(event.id)
        XCTAssertEqual(event.type, .screenView)
        XCTAssertEqual(event.name, "HomeScreen")
        XCTAssertEqual(event.sessionId, "test-session")
    }
    
    func testAnalyticsEventTypes() {
        let types: [AnalyticsEvent.EventType] = [
            .screenView, .navigation, .action, .error,
            .timing, .custom, .userProperty, .conversion
        ]
        
        for type in types {
            XCTAssertNotNil(type.rawValue)
        }
    }
    
    func testAnalyticsEventSources() {
        let sources: [AnalyticsEvent.EventSource] = [
            .router, .deepLink, .universalLink, .notification,
            .widget, .shortcut, .user
        ]
        
        for source in sources {
            XCTAssertNotNil(source.rawValue)
        }
    }
    
    // MARK: - Analytics Value Tests
    
    func testAnalyticsValueString() {
        let value = AnalyticsValue.string("test")
        XCTAssertEqual(value.stringValue, "test")
    }
    
    func testAnalyticsValueInt() {
        let value = AnalyticsValue.int(42)
        XCTAssertEqual(value.stringValue, "42")
    }
    
    func testAnalyticsValueDouble() {
        let value = AnalyticsValue.double(3.14)
        XCTAssertTrue(value.stringValue.contains("3.14"))
    }
    
    func testAnalyticsValueBool() {
        let trueValue = AnalyticsValue.bool(true)
        let falseValue = AnalyticsValue.bool(false)
        
        XCTAssertEqual(trueValue.stringValue, "true")
        XCTAssertEqual(falseValue.stringValue, "false")
    }
    
    func testAnalyticsValueNull() {
        let value = AnalyticsValue.null
        XCTAssertEqual(value.stringValue, "null")
    }
    
    // MARK: - Analytics Configuration Tests
    
    func testDefaultConfiguration() {
        let config = AnalyticsConfiguration.default
        
        XCTAssertTrue(config.isEnabled)
        XCTAssertTrue(config.trackScreenViews)
        XCTAssertTrue(config.trackTiming)
        XCTAssertFalse(config.includeParameters)
        XCTAssertEqual(config.sessionTimeout, 1800)
        XCTAssertTrue(config.excludedPatterns.isEmpty)
        XCTAssertEqual(config.samplingRate, 1.0)
        XCTAssertTrue(config.batchEvents)
    }
    
    func testCustomConfiguration() {
        let config = AnalyticsConfiguration(
            isEnabled: true,
            trackScreenViews: false,
            trackTiming: false,
            includeParameters: true,
            sessionTimeout: 600,
            excludedPatterns: ["/debug", "/admin"],
            samplingRate: 0.5,
            batchEvents: false,
            batchSize: 10,
            batchFlushInterval: 15,
            persistOffline: false,
            maxOfflineEvents: 500
        )
        
        XCTAssertFalse(config.trackScreenViews)
        XCTAssertFalse(config.trackTiming)
        XCTAssertTrue(config.includeParameters)
        XCTAssertEqual(config.sessionTimeout, 600)
        XCTAssertEqual(config.excludedPatterns.count, 2)
        XCTAssertEqual(config.samplingRate, 0.5)
        XCTAssertFalse(config.batchEvents)
    }
    
    func testSamplingRateClamping() {
        let underConfig = AnalyticsConfiguration(samplingRate: -0.5)
        let overConfig = AnalyticsConfiguration(samplingRate: 1.5)
        
        XCTAssertEqual(underConfig.samplingRate, 0.0)
        XCTAssertEqual(overConfig.samplingRate, 1.0)
    }
    
    // MARK: - Console Tracker Tests
    
    func testConsoleTrackerCreation() {
        let tracker = ConsoleAnalyticsTracker(
            prefix: "[Test]",
            includeTimestamps: true,
            verbose: true
        )
        
        XCTAssertEqual(tracker.prefix, "[Test]")
        XCTAssertTrue(tracker.includeTimestamps)
        XCTAssertTrue(tracker.verbose)
    }
    
    func testConsoleTrackerScreenView() async {
        let tracker = ConsoleAnalyticsTracker()
        
        // Should not throw
        await tracker.trackScreenView(
            screenName: "TestScreen",
            parameters: ["key": "value"]
        )
    }
    
    func testConsoleTrackerEvent() async {
        let tracker = ConsoleAnalyticsTracker()
        
        await tracker.trackEvent(
            event: "test_event",
            parameters: ["param": "value"]
        )
    }
    
    func testConsoleTrackerError() async {
        let tracker = ConsoleAnalyticsTracker()
        
        await tracker.trackError(
            error: "Test error",
            route: "/test"
        )
    }
    
    func testConsoleTrackerTiming() async {
        let tracker = ConsoleAnalyticsTracker()
        
        await tracker.trackTiming(
            category: "navigation",
            variable: "load_time",
            value: 0.5,
            label: "home"
        )
    }
    
    // MARK: - Composite Tracker Tests
    
    func testCompositeTrackerForwardsToAll() async {
        var tracker1Called = false
        var tracker2Called = false
        
        let tracker1 = TestAnalyticsTracker { tracker1Called = true }
        let tracker2 = TestAnalyticsTracker { tracker2Called = true }
        
        let composite = CompositeAnalyticsTracker(trackers: [tracker1, tracker2])
        
        await composite.trackScreenView(screenName: "Test", parameters: [:])
        
        XCTAssertTrue(tracker1Called)
        XCTAssertTrue(tracker2Called)
    }
    
    // MARK: - Analytics Session Tests
    
    func testSessionCreation() {
        let session = AnalyticsSession(sessionTimeout: 1800)
        
        XCTAssertNotNil(session.id)
        XCTAssertNotNil(session.startTime)
        XCTAssertEqual(session.screenViewCount, 0)
        XCTAssertEqual(session.eventCount, 0)
    }
    
    func testSessionIsActive() {
        let session = AnalyticsSession(sessionTimeout: 1800)
        
        XCTAssertTrue(session.isActive)
    }
    
    func testSessionDuration() {
        let session = AnalyticsSession()
        
        // Duration should be very small initially
        XCTAssertLessThan(session.duration, 1.0)
    }
}

// MARK: - Auth Middleware Tests

final class AuthMiddlewareTests: XCTestCase {
    
    // MARK: - Auth State Tests
    
    func testAuthStateAuthenticated() {
        let state = AuthState.authenticated(userId: "user123")
        
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(state.userId, "user123")
    }
    
    func testAuthStateUnauthenticated() {
        let state = AuthState.unauthenticated
        
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.userId)
    }
    
    func testAuthStateEquality() {
        let state1 = AuthState.authenticated(userId: "user1")
        let state2 = AuthState.authenticated(userId: "user1")
        let state3 = AuthState.authenticated(userId: "user2")
        
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }
    
    // MARK: - Auth Permission Tests
    
    func testPermissionCreation() {
        let permission = AuthPermission(
            identifier: "posts.read",
            scope: .read,
            level: .basic
        )
        
        XCTAssertEqual(permission.identifier, "posts.read")
        XCTAssertEqual(permission.scope, .read)
        XCTAssertEqual(permission.level, .basic)
    }
    
    func testPermissionConvenienceInitializers() {
        let readPerm = AuthPermission.read("resource")
        let writePerm = AuthPermission.write("resource")
        let adminPerm = AuthPermission.admin("resource")
        
        XCTAssertEqual(readPerm.scope, .read)
        XCTAssertEqual(writePerm.scope, .write)
        XCTAssertEqual(adminPerm.scope, .admin)
    }
    
    func testPermissionLevelComparison() {
        XCTAssertTrue(AuthPermission.PermissionLevel.basic < .standard)
        XCTAssertTrue(AuthPermission.PermissionLevel.standard < .elevated)
        XCTAssertTrue(AuthPermission.PermissionLevel.elevated < .admin)
        XCTAssertTrue(AuthPermission.PermissionLevel.none < .basic)
    }
    
    // MARK: - Auth Role Tests
    
    func testRoleCreation() {
        let permissions: Set<AuthPermission> = [
            .read("posts"),
            .write("posts")
        ]
        
        let role = AuthRole(
            identifier: "editor",
            displayName: "Editor",
            permissions: permissions,
            priority: 5
        )
        
        XCTAssertEqual(role.identifier, "editor")
        XCTAssertEqual(role.displayName, "Editor")
        XCTAssertEqual(role.permissions.count, 2)
        XCTAssertEqual(role.priority, 5)
    }
    
    func testPredefinedRoles() {
        XCTAssertEqual(AuthRole.guest.identifier, "guest")
        XCTAssertEqual(AuthRole.user.identifier, "user")
        XCTAssertEqual(AuthRole.admin.identifier, "admin")
        
        XCTAssertLessThan(AuthRole.guest.priority, AuthRole.user.priority)
        XCTAssertLessThan(AuthRole.user.priority, AuthRole.admin.priority)
    }
    
    // MARK: - Auth Requirement Tests
    
    func testNoAuthRequirement() {
        let requirement = AuthRequirement.none
        
        XCTAssertEqual(requirement.type, .none)
        XCTAssertTrue(requirement.permissions.isEmpty)
        XCTAssertTrue(requirement.roles.isEmpty)
    }
    
    func testAuthenticatedRequirement() {
        let requirement = AuthRequirement.authenticated
        
        XCTAssertEqual(requirement.type, .authenticated)
    }
    
    func testPermissionsRequirement() {
        let permissions: Set<AuthPermission> = [.read("posts"), .write("posts")]
        let requirement = AuthRequirement.permissions(permissions)
        
        XCTAssertEqual(requirement.type, .permissions)
        XCTAssertEqual(requirement.permissions.count, 2)
    }
    
    func testRolesRequirement() {
        let roles: Set<String> = ["admin", "moderator"]
        let requirement = AuthRequirement.roles(roles)
        
        XCTAssertEqual(requirement.type, .roles)
        XCTAssertEqual(requirement.roles.count, 2)
    }
    
    // MARK: - Auth Middleware Error Tests
    
    func testNotAuthenticatedError() {
        let error = AuthMiddlewareError.notAuthenticated(
            attemptedRoute: "/profile",
            redirectTo: "/login"
        )
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.redirectRoute, "/login")
    }
    
    func testInsufficientPermissionsError() {
        let required: Set<AuthPermission> = [.write("posts"), .delete("posts")]
        let missing: Set<AuthPermission> = [.delete("posts")]
        
        let error = AuthMiddlewareError.insufficientPermissions(
            required: required,
            missing: missing
        )
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNil(error.redirectRoute)
    }
    
    func testSessionExpiredError() {
        let error = AuthMiddlewareError.sessionExpired
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.redirectRoute, "/login")
    }
    
    func testAccountLockedError() {
        let error = AuthMiddlewareError.accountLocked
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.redirectRoute, "/account-locked")
    }
    
    // MARK: - Configuration Tests
    
    func testDefaultAuthConfiguration() {
        let config = AuthMiddlewareConfiguration.default
        
        XCTAssertEqual(config.loginRoute, "/login")
        XCTAssertTrue(config.protectedPatterns.isEmpty)
        XCTAssertFalse(config.publicPatterns.isEmpty)
        XCTAssertTrue(config.autoRefresh)
        XCTAssertTrue(config.cacheAuthChecks)
        XCTAssertTrue(config.enableRateLimiting)
        XCTAssertTrue(config.isEnabled)
    }
    
    func testCustomAuthConfiguration() {
        let config = AuthMiddlewareConfiguration(
            loginRoute: "/signin",
            protectedPatterns: ["/admin/*", "/settings/*"],
            publicPatterns: ["/", "/about"],
            autoRefresh: false,
            cacheAuthChecks: false,
            cacheTTL: 120,
            enableRateLimiting: false,
            maxAttemptsPerMinute: 10,
            isEnabled: true
        )
        
        XCTAssertEqual(config.loginRoute, "/signin")
        XCTAssertEqual(config.protectedPatterns.count, 2)
        XCTAssertEqual(config.publicPatterns.count, 2)
        XCTAssertFalse(config.autoRefresh)
        XCTAssertFalse(config.cacheAuthChecks)
        XCTAssertEqual(config.cacheTTL, 120)
        XCTAssertFalse(config.enableRateLimiting)
        XCTAssertEqual(config.maxAttemptsPerMinute, 10)
    }
    
    // MARK: - Mock Auth Provider Tests
    
    func testMockAuthProviderUnauthenticated() async {
        let provider = MockAuthProvider(isAuthenticated: false)
        
        let isAuthenticated = await provider.isAuthenticated
        let userId = await provider.currentUserId
        
        XCTAssertFalse(isAuthenticated)
        XCTAssertNil(userId)
    }
    
    func testMockAuthProviderAuthenticated() async {
        let provider = MockAuthProvider(isAuthenticated: true, userId: "test-user")
        
        let isAuthenticated = await provider.isAuthenticated
        let userId = await provider.currentUserId
        
        XCTAssertTrue(isAuthenticated)
        XCTAssertEqual(userId, "test-user")
    }
    
    func testMockAuthProviderPermissions() async {
        let provider = MockAuthProvider(
            isAuthenticated: true,
            permissions: [.read("posts"), .write("posts")]
        )
        
        let hasRead = await provider.hasPermission(AuthPermission.read("posts"))
        let hasDelete = await provider.hasPermission(AuthPermission.delete("posts"))
        
        XCTAssertTrue(hasRead)
        XCTAssertFalse(hasDelete)
    }
    
    func testMockAuthProviderRoles() async {
        let provider = MockAuthProvider(
            isAuthenticated: true,
            roles: [.user]
        )
        
        let hasUserRole = await provider.hasRole("user")
        let hasAdminRole = await provider.hasRole("admin")
        
        XCTAssertTrue(hasUserRole)
        XCTAssertFalse(hasAdminRole)
    }
    
    func testMockAuthProviderSignOut() async throws {
        let provider = MockAuthProvider(isAuthenticated: true, userId: "user123")
        
        try await provider.signOut()
        
        let isAuthenticated = await provider.isAuthenticated
        XCTAssertFalse(isAuthenticated)
    }
    
    func testMockAuthProviderSetAuthenticated() async {
        let provider = MockAuthProvider(isAuthenticated: false)
        
        await provider.setAuthenticated(true, userId: "new-user")
        
        let isAuthenticated = await provider.isAuthenticated
        let userId = await provider.currentUserId
        
        XCTAssertTrue(isAuthenticated)
        XCTAssertEqual(userId, "new-user")
    }
}

// MARK: - Test Helpers

private struct TestAnalyticsTracker: AnalyticsTracker {
    let onTrack: () -> Void
    
    func trackScreenView(screenName: String, parameters: [String: String]) async {
        onTrack()
    }
    
    func trackEvent(event: String, parameters: [String: String]) async {
        onTrack()
    }
    
    func trackError(error: String, route: String) async {
        onTrack()
    }
}
