import Testing
@testable import SwiftRouter

@Suite("URL patterns")
struct URLPatternTests {
    @Test func parsesEverySegmentKind() throws {
        let pattern = try URLPattern("/users/:id/files/*")
        #expect(pattern.segments == [.literal("users"), .parameter("id"), .literal("files"), .wildcard])
        #expect(pattern.description == "/users/:id/files/*")
        #expect(try URLPattern("/").segments.isEmpty)
        #expect(try URLPattern("/tabs/:tab?").segments == [.literal("tabs"), .optionalParameter("tab")])
    }

    @Test(arguments: [
        ("products/:id", URLPatternError.missingLeadingSlash),
        ("/a/:", .invalidParameterName("")),
        ("/a/:9id", .invalidParameterName("9id")),
        ("/a/:id-x", .invalidParameterName("id-x")),
        ("/a/:id/:id", .duplicateParameter("id")),
        ("/a/*/b", .wildcardNotLast),
        ("/a/:x?/b", .optionalParameterNotLast("x")),
        ("/a/..", .invalidLiteral("..")),
        ("/a/./b", .invalidLiteral(".")),
        ("/a/b\u{0}c", .invalidLiteral("b\u{0}c")),
    ])
    func rejectsInvalidPatterns(pattern: String, error: URLPatternError) {
        #expect(throws: error) { try URLPattern(pattern) }
    }

    @Test func matchesParametersAndRejectsExtraSegments() throws {
        let pattern = try URLPattern("/users/:id/posts/:post")
        let found = try #require(pattern.match(["users", "7", "posts", "hello world"]))
        #expect(found.parameters == ["id": "7", "post": "hello world"])
        #expect(pattern.match(["users", "7", "posts"]) == nil)
        #expect(pattern.match(["users", "7", "posts", "1", "2"]) == nil)
        #expect(pattern.match(["Users", "7", "posts", "1"]) == nil)
    }

    @Test func optionalParameterMayBeMissing() throws {
        let pattern = try URLPattern("/tabs/:tab?")
        #expect(pattern.match(["tabs"])?.parameters == [:])
        #expect(pattern.match(["tabs", "search"])?.parameters == ["tab": "search"])
        #expect(pattern.match(["tabs", "search", "x"]) == nil)
    }

    @Test func wildcardTakesTheRestIncludingNothing() throws {
        let pattern = try URLPattern("/docs/*")
        #expect(pattern.match(["docs"])?.rest == [])
        #expect(pattern.match(["docs", "a", "b"])?.rest == ["a", "b"])
        #expect(pattern.match(["blog", "a"]) == nil)
    }

    @Test func caseInsensitiveMatchingAppliesToLiteralsOnly() throws {
        let pattern = try URLPattern("/Products/:name")
        let found = try #require(pattern.match(["products", "MiXeD"], literalMatching: .caseInsensitive))
        #expect(found.parameters == ["name": "MiXeD"])
        #expect(pattern.match(["products", "x"], literalMatching: .exact) == nil)
    }

    @Test func specificityOrdersLiteralsBeforeParametersBeforeWildcards() throws {
        let literal = try URLPattern("/products/new").specificity
        let parameter = try URLPattern("/products/:id").specificity
        let optional = try URLPattern("/products/:id?").specificity
        let wildcard = try URLPattern("/products/*").specificity
        #expect(parameter.lexicographicallyPrecedes(literal))
        #expect(optional.lexicographicallyPrecedes(parameter))
        #expect(wildcard.lexicographicallyPrecedes(optional))
    }

    @Test func buildsAPercentEncodedPath() throws {
        let pattern = try URLPattern("/search/:query/:page?")
        #expect(try pattern.path(with: ["query": "red shoes/50%"]) == "/search/red%20shoes%2F50%25")
        #expect(try pattern.path(with: ["query": "a", "page": "2"]) == "/search/a/2")
        #expect(try URLPattern("/files/*").path(with: [:], rest: ["a b", "c"]) == "/files/a%20b/c")
    }

    @Test(arguments: ["", ".", "..", "line\nbreak", "\u{202E}txt"])
    func refusesValuesThatCouldNotBeReadBack(value: String) throws {
        let pattern = try URLPattern("/p/:id")
        #expect(throws: URLPatternError.invalidValue(name: "id")) { try pattern.path(with: ["id": value]) }
    }

    @Test func refusesAMissingRequiredValue() throws {
        #expect(throws: URLPatternError.missingValue("id")) { try URLPattern("/p/:id").path(with: [:]) }
    }
}
