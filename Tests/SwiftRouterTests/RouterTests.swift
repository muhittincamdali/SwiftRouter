//
//  RouterTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

final class RouterTests: XCTestCase {
    
    // MARK: - Properties
    
    var router: Router!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        router = Router()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    // MARK: - Basic Navigation Tests
    
    func testRouterInitialization() {
        XCTAssertNotNil(router)
        XCTAssertTrue(router.navigationStack.isEmpty)
    }
    
    func testPushRoute() async throws {
        let testRoute = TestRoute(id: "test-1", pattern: "/test")
        
        try await router.push(testRoute)
        
        XCTAssertEqual(router.navigationStack.count, 1)
    }
    
    func testPopRoute() async throws {
        let route1 = TestRoute(id: "test-1", pattern: "/test1")
        let route2 = TestRoute(id: "test-2", pattern: "/test2")
        
        try await router.push(route1)
        try await router.push(route2)
        
        XCTAssertEqual(router.navigationStack.count, 2)
        
        await router.pop()
        
        XCTAssertEqual(router.navigationStack.count, 1)
    }
    
    func testPopToRoot() async throws {
        let route1 = TestRoute(id: "test-1", pattern: "/test1")
        let route2 = TestRoute(id: "test-2", pattern: "/test2")
        let route3 = TestRoute(id: "test-3", pattern: "/test3")
        
        try await router.push(route1)
        try await router.push(route2)
        try await router.push(route3)
        
        XCTAssertEqual(router.navigationStack.count, 3)
        
        await router.popToRoot()
        
        XCTAssertTrue(router.navigationStack.isEmpty)
    }
    
    // MARK: - Route Registration Tests
    
    func testRegisterRoute() {
        let pattern = "/users/:userId"
        
        router.register(pattern: pattern) { params in
            TestRoute(id: "user", pattern: pattern)
        }
        
        XCTAssertTrue(router.isPatternRegistered(pattern))
    }
    
    func testNavigateToRegisteredRoute() async throws {
        let pattern = "/products/:productId"
        
        router.register(pattern: pattern) { params in
            TestRoute(id: params["productId"] ?? "unknown", pattern: pattern)
        }
        
        try await router.navigate(to: "/products/123")
        
        XCTAssertEqual(router.navigationStack.count, 1)
    }
    
    func testNavigateToUnregisteredRoute() async {
        do {
            try await router.navigate(to: "/unknown/path")
            XCTFail("Should throw error for unregistered route")
        } catch {
            XCTAssertTrue(error is RouterError)
        }
    }
    
    // MARK: - Navigation Stack Tests
    
    func testNavigationStackOrder() async throws {
        let routes = [
            TestRoute(id: "1", pattern: "/1"),
            TestRoute(id: "2", pattern: "/2"),
            TestRoute(id: "3", pattern: "/3")
        ]
        
        for route in routes {
            try await router.push(route)
        }
        
        XCTAssertEqual(router.navigationStack.count, 3)
    }
    
    func testCanGoBack() async throws {
        XCTAssertFalse(router.canGoBack)
        
        try await router.push(TestRoute(id: "1", pattern: "/1"))
        
        XCTAssertFalse(router.canGoBack)
        
        try await router.push(TestRoute(id: "2", pattern: "/2"))
        
        XCTAssertTrue(router.canGoBack)
    }
    
    // MARK: - Replace Tests
    
    func testReplaceRoute() async throws {
        let route1 = TestRoute(id: "1", pattern: "/1")
        let route2 = TestRoute(id: "2", pattern: "/2")
        
        try await router.push(route1)
        XCTAssertEqual(router.navigationStack.count, 1)
        
        try await router.replace(with: route2)
        XCTAssertEqual(router.navigationStack.count, 1)
    }
}

// MARK: - Test Route

struct TestRoute: Route {
    let id: String
    static var pattern: String = "/test"
    var routePattern: String
    
    init(id: String, pattern: String) {
        self.id = id
        self.routePattern = pattern
    }
}
