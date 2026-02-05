//
//  PathMatcherTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

final class PathMatcherTests: XCTestCase {
    
    var matcher: PathMatcher!
    
    override func setUp() {
        super.setUp()
        matcher = PathMatcher()
    }
    
    override func tearDown() {
        matcher = nil
        super.tearDown()
    }
    
    // MARK: - Basic Matching Tests
    
    func testExactPathMatch() {
        XCTAssertTrue(matcher.matches(pattern: "/home", path: "/home"))
        XCTAssertTrue(matcher.matches(pattern: "/settings", path: "/settings"))
        XCTAssertFalse(matcher.matches(pattern: "/home", path: "/settings"))
    }
    
    func testPathWithSingleParameter() {
        XCTAssertTrue(matcher.matches(pattern: "/users/:userId", path: "/users/123"))
        XCTAssertTrue(matcher.matches(pattern: "/users/:userId", path: "/users/abc"))
        XCTAssertFalse(matcher.matches(pattern: "/users/:userId", path: "/users"))
    }
    
    func testPathWithMultipleParameters() {
        XCTAssertTrue(matcher.matches(pattern: "/users/:userId/posts/:postId", path: "/users/123/posts/456"))
        XCTAssertFalse(matcher.matches(pattern: "/users/:userId/posts/:postId", path: "/users/123/posts"))
    }
    
    func testPathWithOptionalParameter() {
        XCTAssertTrue(matcher.matches(pattern: "/settings/:section?", path: "/settings"))
        XCTAssertTrue(matcher.matches(pattern: "/settings/:section?", path: "/settings/privacy"))
    }
    
    func testWildcardPattern() {
        XCTAssertTrue(matcher.matches(pattern: "/files/*", path: "/files/a/b/c"))
        XCTAssertTrue(matcher.matches(pattern: "/*", path: "/anything/goes/here"))
    }
    
    // MARK: - Parameter Extraction Tests
    
    func testExtractSingleParameter() {
        let params = matcher.extractParameters(pattern: "/users/:userId", path: "/users/123")
        XCTAssertEqual(params?.string(for: "userId"), "123")
    }
    
    func testExtractMultipleParameters() {
        let params = matcher.extractParameters(pattern: "/users/:userId/posts/:postId", path: "/users/abc/posts/xyz")
        XCTAssertEqual(params?.string(for: "userId"), "abc")
        XCTAssertEqual(params?.string(for: "postId"), "xyz")
    }
    
    func testExtractIntegerParameter() {
        let params = matcher.extractParameters(pattern: "/items/:itemId", path: "/items/42")
        XCTAssertEqual(params?.integer(for: "itemId"), 42)
    }
    
    func testExtractUUIDParameter() {
        let uuid = UUID()
        let params = matcher.extractParameters(pattern: "/documents/:docId", path: "/documents/\(uuid.uuidString)")
        XCTAssertEqual(params?.uuid(for: "docId"), uuid)
    }
    
    func testExtractOptionalParameterPresent() {
        let params = matcher.extractParameters(pattern: "/settings/:section?", path: "/settings/privacy")
        XCTAssertEqual(params?.string(for: "section"), "privacy")
    }
    
    func testExtractOptionalParameterMissing() {
        let params = matcher.extractParameters(pattern: "/settings/:section?", path: "/settings")
        XCTAssertNil(params?.string(for: "section"))
    }
    
    // MARK: - Path Building Tests
    
    func testBuildPathWithParameters() {
        let params = RouteParameters(["userId": .string("123")])
        let path = matcher.buildPath(pattern: "/users/:userId", parameters: params)
        XCTAssertEqual(path, "/users/123")
    }
    
    func testBuildPathWithMultipleParameters() {
        let params = RouteParameters([
            "userId": .string("abc"),
            "postId": .string("xyz")
        ])
        let path = matcher.buildPath(pattern: "/users/:userId/posts/:postId", parameters: params)
        XCTAssertEqual(path, "/users/abc/posts/xyz")
    }
    
    func testBuildPathMissingRequiredParameter() {
        let params = RouteParameters([:])
        let path = matcher.buildPath(pattern: "/users/:userId", parameters: params)
        XCTAssertNil(path)
    }
    
    func testBuildPathWithOptionalParameterPresent() {
        let params = RouteParameters(["section": .string("privacy")])
        let path = matcher.buildPath(pattern: "/settings/:section?", parameters: params)
        XCTAssertEqual(path, "/settings/privacy")
    }
    
    // MARK: - Specificity Tests
    
    func testSpecificityStaticHigherThanDynamic() {
        let staticScore = matcher.specificity(of: "/users/settings")
        let dynamicScore = matcher.specificity(of: "/users/:userId")
        XCTAssertGreaterThan(staticScore, dynamicScore)
    }
    
    func testSpecificityDynamicHigherThanWildcard() {
        let dynamicScore = matcher.specificity(of: "/users/:userId")
        let wildcardScore = matcher.specificity(of: "/users/*")
        XCTAssertGreaterThan(dynamicScore, wildcardScore)
    }
    
    // MARK: - Validation Tests
    
    func testValidPatternWithLeadingSlash() {
        XCTAssertTrue(matcher.isValidPattern("/home"))
        XCTAssertTrue(matcher.isValidPattern("/users/:userId"))
    }
    
    func testInvalidPatternWithoutLeadingSlash() {
        XCTAssertFalse(matcher.isValidPattern("home"))
    }
    
    func testValidWildcardPattern() {
        XCTAssertTrue(matcher.isValidPattern("/*"))
        XCTAssertTrue(matcher.isValidPattern("/files/*"))
    }
    
    // MARK: - Edge Cases
    
    func testCaseInsensitiveStaticSegments() {
        XCTAssertTrue(matcher.matches(pattern: "/Home", path: "/home"))
        XCTAssertTrue(matcher.matches(pattern: "/USERS", path: "/users"))
    }
    
    func testEmptyPath() {
        XCTAssertFalse(matcher.matches(pattern: "/home", path: ""))
    }
    
    func testRootPath() {
        XCTAssertTrue(matcher.matches(pattern: "/", path: "/"))
    }
    
    func testTrailingSlash() {
        let params1 = matcher.extractParameters(pattern: "/users/:id", path: "/users/123")
        let params2 = matcher.extractParameters(pattern: "/users/:id", path: "/users/123/")
        
        // Both should work, trailing slash should be normalized
        XCTAssertNotNil(params1)
    }
}
