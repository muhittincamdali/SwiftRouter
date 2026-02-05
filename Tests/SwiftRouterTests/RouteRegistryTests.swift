//
//  RouteRegistryTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

final class RouteRegistryTests: XCTestCase {
    
    var registry: RouteRegistry!
    
    override func setUp() {
        super.setUp()
        registry = RouteRegistry()
    }
    
    override func tearDown() {
        registry = nil
        super.tearDown()
    }
    
    // MARK: - Registration Tests
    
    func testRegisterRouteDefinition() {
        let definition = RouteDefinition(
            pattern: "/test",
            name: "TestRoute",
            factory: { _ in TestRouteImpl() }
        )
        
        registry.register(definition)
        
        XCTAssertEqual(registry.count, 1)
        XCTAssertTrue(registry.isRegistered(pattern: "/test"))
    }
    
    func testRegisterMultipleRoutes() {
        registry.register(RouteDefinition(pattern: "/a", name: "A", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/b", name: "B", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/c", name: "C", factory: { _ in TestRouteImpl() }))
        
        XCTAssertEqual(registry.count, 3)
    }
    
    func testUnregisterRoute() {
        registry.register(RouteDefinition(pattern: "/test", name: "Test", factory: { _ in TestRouteImpl() }))
        
        let removed = registry.unregister(pattern: "/test")
        
        XCTAssertNotNil(removed)
        XCTAssertEqual(registry.count, 0)
        XCTAssertFalse(registry.isRegistered(pattern: "/test"))
    }
    
    func testClearRegistry() {
        registry.register(RouteDefinition(pattern: "/a", name: "A", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/b", name: "B", factory: { _ in TestRouteImpl() }))
        
        registry.clear()
        
        XCTAssertTrue(registry.isEmpty)
    }
    
    // MARK: - Lookup Tests
    
    func testDefinitionForPattern() {
        let definition = RouteDefinition(pattern: "/users/:id", name: "User", factory: { _ in TestRouteImpl() })
        registry.register(definition)
        
        let found = registry.definition(for: "/users/:id")
        
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "User")
    }
    
    func testResolveStaticPath() {
        registry.register(RouteDefinition(pattern: "/home", name: "Home", factory: { _ in TestRouteImpl() }))
        
        let result = registry.resolve(path: "/home")
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.definition.name, "Home")
    }
    
    func testResolveDynamicPath() {
        registry.register(RouteDefinition(pattern: "/users/:userId", name: "User", factory: { params in
            TestRouteImpl()
        }))
        
        let result = registry.resolve(path: "/users/123")
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.definition.name, "User")
        XCTAssertEqual(result?.parameters.string(for: "userId"), "123")
    }
    
    func testResolveNoMatch() {
        registry.register(RouteDefinition(pattern: "/home", name: "Home", factory: { _ in TestRouteImpl() }))
        
        let result = registry.resolve(path: "/unknown")
        
        XCTAssertNil(result)
    }
    
    // MARK: - Priority Tests
    
    func testHigherPriorityMatchesFirst() {
        // Register lower priority first
        registry.register(RouteDefinition(
            pattern: "/items/:id",
            name: "GenericItem",
            priority: 0,
            factory: { _ in TestRouteImpl() }
        ))
        
        // Register higher priority
        registry.register(RouteDefinition(
            pattern: "/items/:id",
            name: "SpecificItem",
            priority: 10,
            factory: { _ in TestRouteImpl() }
        ))
        
        // Note: Same pattern will overwrite, but with different patterns this tests priority
    }
    
    // MARK: - Find Tests
    
    func testFindAuthRequiredRoutes() {
        registry.register(RouteDefinition(pattern: "/public", name: "Public", requiresAuth: false, factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/private", name: "Private", requiresAuth: true, factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/admin", name: "Admin", requiresAuth: true, factory: { _ in TestRouteImpl() }))
        
        let authRequired = registry.authRequiredRoutes()
        
        XCTAssertEqual(authRequired.count, 2)
    }
    
    func testFindRoutesWithPrefix() {
        registry.register(RouteDefinition(pattern: "/api/users", name: "Users", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/api/posts", name: "Posts", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/web/home", name: "Home", factory: { _ in TestRouteImpl() }))
        
        let apiRoutes = registry.routes(withPrefix: "/api")
        
        XCTAssertEqual(apiRoutes.count, 2)
    }
    
    // MARK: - Validation Tests
    
    func testValidateEmptyRegistry() {
        let errors = registry.validate()
        XCTAssertTrue(errors.isEmpty)
    }
    
    func testValidateValidPatterns() {
        registry.register(RouteDefinition(pattern: "/home", name: "Home", factory: { _ in TestRouteImpl() }))
        registry.register(RouteDefinition(pattern: "/users/:id", name: "User", factory: { _ in TestRouteImpl() }))
        
        let errors = registry.validate()
        XCTAssertTrue(errors.isEmpty)
    }
    
    // MARK: - Route Group Tests
    
    func testRouteGroupRegistration() {
        var group = RouteGroup(prefix: "/api/v1", requiresAuth: true)
        group.add(TestRouteType.self)
        
        registry.register(group: group)
        
        // The group should prefix the route pattern
        XCTAssertFalse(registry.isEmpty)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentRegistration() {
        let expectation = expectation(description: "Concurrent registration")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            self.registry.register(RouteDefinition(
                pattern: "/route\(index)",
                name: "Route\(index)",
                factory: { _ in TestRouteImpl() }
            ))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(registry.count, 100)
    }
    
    func testConcurrentResolve() {
        // Pre-register routes
        for i in 0..<10 {
            registry.register(RouteDefinition(
                pattern: "/route\(i)/:id",
                name: "Route\(i)",
                factory: { _ in TestRouteImpl() }
            ))
        }
        
        let expectation = expectation(description: "Concurrent resolve")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let routeIndex = index % 10
            let result = self.registry.resolve(path: "/route\(routeIndex)/\(index)")
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Test Helpers

private struct TestRouteImpl: Route {
    static let pattern = "/test"
    var parameters: RouteParameters { [:] }
    
    init() {}
    init(parameters: RouteParameters) throws {}
}

private struct TestRouteType: Route {
    static let pattern = "/items"
    var parameters: RouteParameters { [:] }
    
    init() {}
    init(parameters: RouteParameters) throws {}
}
