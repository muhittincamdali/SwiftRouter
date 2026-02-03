//
//  DeepLinkTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

final class DeepLinkTests: XCTestCase {
    
    // MARK: - Schema Tests
    
    func testDeepLinkSchemaCreation() {
        let schema = DeepLinkSchema(
            scheme: "myapp",
            host: "example.com",
            pathPattern: "/users/:userId/profile",
            requiredParams: ["token"],
            optionalParams: ["ref": "organic"]
        )
        
        XCTAssertEqual(schema.scheme, "myapp")
        XCTAssertEqual(schema.host, "example.com")
        XCTAssertEqual(schema.pathPattern, "/users/:userId/profile")
        XCTAssertTrue(schema.requiredParams.contains("token"))
        XCTAssertEqual(schema.optionalParams["ref"], "organic")
    }
    
    func testSchemaMatchesURL() {
        let schema = DeepLinkSchema(
            scheme: "myapp",
            host: nil,
            pathPattern: "/products/:productId"
        )
        
        let matchingURL = URL(string: "myapp://products/123")!
        let nonMatchingURL = URL(string: "otherapp://products/123")!
        
        XCTAssertTrue(schema.matches(matchingURL))
        XCTAssertFalse(schema.matches(nonMatchingURL))
    }
    
    func testSchemaExtractsParameters() {
        let schema = DeepLinkSchema(
            scheme: "myapp",
            host: nil,
            pathPattern: "/users/:userId/posts/:postId",
            optionalParams: ["source": "default"]
        )
        
        let url = URL(string: "myapp://users/42/posts/99?ref=email")!
        let params = schema.extractParameters(from: url)
        
        XCTAssertEqual(params["userId"], "42")
        XCTAssertEqual(params["postId"], "99")
        XCTAssertEqual(params["ref"], "email")
        XCTAssertEqual(params["source"], "default")
    }
    
    func testSchemaWithRequiredQueryParams() {
        let schema = DeepLinkSchema(
            scheme: "https",
            host: "example.com",
            pathPattern: "/activate",
            requiredParams: ["code"]
        )
        
        let validURL = URL(string: "https://example.com/activate?code=ABC123")!
        let invalidURL = URL(string: "https://example.com/activate")!
        
        XCTAssertTrue(schema.matches(validURL))
        XCTAssertFalse(schema.matches(invalidURL))
    }
    
    // MARK: - Deep Link Route Tests
    
    func testDeepLinkRouteCreation() {
        let schema = DeepLinkSchema(
            scheme: "myapp",
            pathPattern: "/test"
        )
        
        let route = DeepLinkRoute(
            originalURL: URL(string: "myapp://test")!,
            schema: schema,
            parameters: ["key": "value"],
            routeIdentifier: "test-route"
        )
        
        XCTAssertNotNil(route.id)
        XCTAssertEqual(route.routeIdentifier, "test-route")
        XCTAssertEqual(route.parameters["key"], "value")
    }
    
    // MARK: - Error Tests
    
    func testDeepLinkErrorDescriptions() {
        let errors: [DeepLinkError] = [
            .invalidURL,
            .noMatchingSchema,
            .missingRequiredParameter("token"),
            .invalidParameterFormat(parameter: "date", expected: "ISO8601"),
            .routeNotFound("unknown"),
            .handlerNotRegistered,
            .authenticationRequired,
            .rateLimitExceeded,
            .expiredLink,
            .malformedLink(reason: "missing path"),
            .parsingError(reason: "unexpected format")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Handler Tests
    
    @MainActor
    func testHandlerRegistration() async {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(
            scheme: "myapp",
            pathPattern: "/home"
        )
        
        handler.register(schema: schema, routeIdentifier: "home")
        
        XCTAssertEqual(handler.registeredSchemas.count, 1)
    }
    
    @MainActor
    func testHandlerCanHandle() async {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(
            scheme: "myapp",
            pathPattern: "/settings"
        )
        
        handler.register(schema: schema, routeIdentifier: "settings")
        
        let validURL = URL(string: "myapp://settings")!
        XCTAssertTrue(handler.canHandle(url: validURL))
    }
    
    @MainActor
    func testHandlerProcessesURL() async throws {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(
            scheme: "myapp",
            pathPattern: "/profile/:userId"
        )
        
        handler.register(schema: schema, routeIdentifier: "user-profile")
        
        let url = URL(string: "myapp://profile/12345")!
        let route = try await handler.handle(url: url)
        
        XCTAssertEqual(route.routeIdentifier, "user-profile")
        XCTAssertEqual(route.parameters["userId"], "12345")
    }
    
    @MainActor
    func testHandlerFailsForUnknownURL() async {
        let handler = AdvancedDeepLinkHandler()
        
        let url = URL(string: "myapp://unknown/path")!
        
        do {
            _ = try await handler.handle(url: url)
            XCTFail("Should throw noMatchingSchema error")
        } catch {
            XCTAssertTrue(error is DeepLinkError)
        }
    }
    
    @MainActor
    func testHandlerState() async throws {
        let handler = AdvancedDeepLinkHandler()
        
        XCTAssertEqual(handler.state, .idle)
        
        let schema = DeepLinkSchema(scheme: "myapp", pathPattern: "/test")
        handler.register(schema: schema, routeIdentifier: "test")
        
        let url = URL(string: "myapp://test")!
        _ = try await handler.handle(url: url)
        
        XCTAssertEqual(handler.state, .completed)
    }
    
    @MainActor
    func testHandlerReset() async throws {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(scheme: "myapp", pathPattern: "/test")
        handler.register(schema: schema, routeIdentifier: "test")
        
        let url = URL(string: "myapp://test")!
        _ = try await handler.handle(url: url)
        
        XCTAssertNotNil(handler.pendingRoute)
        
        handler.reset()
        
        XCTAssertNil(handler.pendingRoute)
        XCTAssertEqual(handler.state, .idle)
    }
    
    // MARK: - Preprocessor Tests
    
    @MainActor
    func testHandlerWithPreprocessor() async throws {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(scheme: "myapp", pathPattern: "/normalized")
        handler.register(schema: schema, routeIdentifier: "normalized")
        
        // Add preprocessor that normalizes URLs
        handler.addPreprocessor { url in
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.path = components.path.lowercased()
            return components.url!
        }
        
        let url = URL(string: "myapp://NORMALIZED")!
        let route = try await handler.handle(url: url)
        
        XCTAssertEqual(route.routeIdentifier, "normalized")
    }
    
    // MARK: - Validator Tests
    
    @MainActor
    func testHandlerWithValidator() async {
        let handler = AdvancedDeepLinkHandler()
        
        let schema = DeepLinkSchema(
            scheme: "myapp",
            pathPattern: "/admin/:section"
        )
        handler.register(schema: schema, routeIdentifier: "admin")
        
        // Add validator that rejects admin routes
        handler.addValidator { route in
            return route.routeIdentifier != "admin"
        }
        
        let url = URL(string: "myapp://admin/users")!
        
        do {
            _ = try await handler.handle(url: url)
            XCTFail("Should throw authenticationRequired error")
        } catch {
            XCTAssertTrue(error is DeepLinkError)
        }
    }
    
    // MARK: - Configuration Tests
    
    func testHandlerConfiguration() {
        let config = AdvancedDeepLinkHandler.Configuration(
            enableCaching: true,
            cacheExpiration: 600,
            enableRateLimiting: true,
            rateLimitWindow: 120,
            rateLimitMaxRequests: 50,
            enableAnalytics: true,
            enableLogging: false,
            preprocessTimeout: 15
        )
        
        XCTAssertTrue(config.enableCaching)
        XCTAssertEqual(config.cacheExpiration, 600)
        XCTAssertTrue(config.enableRateLimiting)
        XCTAssertEqual(config.rateLimitWindow, 120)
        XCTAssertEqual(config.rateLimitMaxRequests, 50)
        XCTAssertTrue(config.enableAnalytics)
        XCTAssertFalse(config.enableLogging)
        XCTAssertEqual(config.preprocessTimeout, 15)
    }
    
    func testDefaultConfiguration() {
        let config = AdvancedDeepLinkHandler.Configuration.default
        
        XCTAssertTrue(config.enableCaching)
        XCTAssertTrue(config.enableRateLimiting)
        XCTAssertTrue(config.enableAnalytics)
        XCTAssertTrue(config.enableLogging)
    }
}
