import Foundation
import Testing
@testable import SwiftRouter

/// The links of a small shop: a catalog, products with reviews, an account area and a sheet.
private func shopLinks(limits: DeepLinkLimits = .default) -> DeepLinks<TestRoute> {
    var links = DeepLinks<TestRoute>(schemes: ["Shop"], hosts: ["shop.example.com", "*.example.org"], limits: limits)
    links.add("/catalog") { _ in [.catalog] }
    links.add("/products/:id") { match in match.int("id").map { [.catalog, .product($0)] } }
    links.add("/products/:id/reviews") { match in match.int("id").map { [.catalog, .product($0), .reviews($0)] } }
    links.add("/account/orders") { _ in [.account, .orders] }
    links.add("/settings", entries: { _ in [.sheet(.settings)] })
    return links
}

private func entries(_ resolution: DeepLinkResolution<TestRoute>) -> [RouteEntry<TestRoute>]? {
    if case .matched(let entries, _) = resolution { return entries }
    return nil
}

private func rejection(_ resolution: DeepLinkResolution<TestRoute>) -> DeepLinkRejection? {
    if case .rejected(let reason) = resolution { return reason }
    return nil
}

private func url(_ text: String) throws -> URL {
    try #require(URL(string: text))
}

@Suite("Deep links: schemes and hosts")
struct DeepLinkHostTests {
    @Test func customSchemeReadsTheHostAsTheFirstSegment() throws {
        let found = entries(shopLinks().resolve(try url("shop://products/42")))
        #expect(found == [.push(.catalog), .push(.product(42))])
        #expect(entries(shopLinks().resolve(try url("SHOP://products/42"))) == found)
        #expect(entries(shopLinks().resolve(try url("shop:///products/42"))) == found)
    }

    @Test func universalLinkOnAnAllowedHost() throws {
        let found = entries(shopLinks().resolve(try url("https://SHOP.example.com./products/7/reviews?ref=mail#top")))
        #expect(found == [.push(.catalog), .push(.product(7)), .push(.reviews(7))])
    }

    @Test(arguments: [
        ("https://evil.com/products/1", DeepLinkRejection.hostNotAllowed),
        ("https://shop.example.com.evil.com/products/1", .hostNotAllowed),
        ("https://example.org/catalog", .hostNotAllowed),
        ("https://badexample.org/catalog", .hostNotAllowed),
        ("https://evil.com%2F.example.org/catalog", .hostNotAllowed),
        ("https://evil.com%40m.example.org/catalog", .hostNotAllowed),
        ("https://m%2Eexample.org/catalog", .hostNotAllowed),
        ("https://a_b.example.org/catalog", .hostNotAllowed),
        ("https://-m.example.org/catalog", .hostNotAllowed),
        ("https://m..example.org/catalog", .hostNotAllowed),
        ("https://shop.example.com:8443/catalog", .hostNotAllowed),
        ("https://shop.example.com:80/catalog", .hostNotAllowed),
        ("http://shop.example.com/catalog", .unsupportedScheme),
        ("ftp://shop.example.com/catalog", .unsupportedScheme),
        ("javascript:alert(1)", .unsupportedScheme),
        ("https://user:secret@shop.example.com/catalog", .credentialsNotAllowed),
        ("shop://admin@catalog", .credentialsNotAllowed),
    ])
    func refusesOtherSchemesHostsAndCredentials(text: String, reason: DeepLinkRejection) throws {
        #expect(rejection(shopLinks().resolve(try url(text))) == reason)
    }

    @Test func wildcardHostAcceptsSubdomainsOnly() throws {
        #expect(entries(shopLinks().resolve(try url("https://m.example.org/catalog"))) == [.push(.catalog)])
        #expect(entries(shopLinks().resolve(try url("https://a.b.example.org/catalog"))) == [.push(.catalog)])
    }

    @Test func theDefaultPortAndInternationalNamesAreAccepted() throws {
        #expect(entries(shopLinks().resolve(try url("https://shop.example.com:443/catalog"))) == [.push(.catalog)])
        #expect(entries(shopLinks().resolve(try url("https://bücher.example.org/catalog"))) == [.push(.catalog)])
        #expect(entries(shopLinks().resolve(try url("https://xn--bcher-kva.example.org/catalog"))) == [.push(.catalog)])
    }

    @Test func emptyConfigurationAcceptsNoURL() throws {
        var links = DeepLinks<TestRoute>()
        links.add("/catalog") { _ in [.catalog] }
        #expect(rejection(links.resolve(try url("https://shop.example.com/catalog"))) == .hostNotAllowed)
        #expect(rejection(links.resolve(try url("shop://catalog"))) == .unsupportedScheme)
        #expect(entries(links.resolve(path: "/catalog")) == [.push(.catalog)])
    }
}

@Suite("Deep links: matching")
struct DeepLinkMatchingTests {
    @Test func theMostSpecificPatternWinsWhateverTheOrder() throws {
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add("/products/*") { _ in [.catalog] }
        links.add("/products/:id") { match in match.int("id").map { [.product($0)] } }
        links.add("/products/settings") { _ in [.settings] }
        #expect(entries(links.resolve(try url("shop://products/settings"))) == [.push(.settings)])
        #expect(entries(links.resolve(try url("shop://products/5"))) == [.push(.product(5))])
        #expect(entries(links.resolve(try url("shop://products/a/b"))) == [.push(.catalog)])
        #expect(links.patterns.map(\.description) == ["/products/settings", "/products/:id", "/products/*"])
    }

    @Test func aHandlerReturningNilPassesTheURLToTheNextPattern() throws {
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add("/products/:id") { match in match.int("id").map { [.product($0)] } }
        links.add("/products/*") { _ in [.catalog] }
        #expect(entries(links.resolve(try url("shop://products/abc"))) == [.push(.catalog)])
    }

    @Test func noMatchIsUnmatchedNotRejected() throws {
        guard case .unmatched = shopLinks().resolve(try url("shop://nowhere")) else {
            Issue.record("expected .unmatched")
            return
        }
    }

    @Test func entriesHandlersCanPresentSheets() throws {
        #expect(entries(shopLinks().resolve(try url("shop://settings"))) == [.sheet(.settings)])
    }

    @Test func caseInsensitiveLiteralsAreOptIn() throws {
        var links = DeepLinks<TestRoute>(schemes: ["shop"], literalMatching: .caseInsensitive)
        links.add("/catalog") { _ in [.catalog] }
        #expect(entries(links.resolve(try url("shop://CATALOG"))) == [.push(.catalog)])
        guard case .unmatched = shopLinks().resolve(try url("shop://CATALOG")) else {
            Issue.record("exact matching should not match a different case")
            return
        }
    }

    @Test func inAppPathsNeedALeadingSlashAndNoHost() {
        let links = shopLinks()
        #expect(entries(links.resolve(path: "/products/3?ref=push")) == [.push(.catalog), .push(.product(3))])
        #expect(rejection(links.resolve(path: "products/3")) == .malformedURL)
        #expect(rejection(links.resolve(path: "//evil.com/products/3")) == .malformedURL)
        #expect(rejection(links.resolve(path: "https://shop.example.com/catalog")) == .malformedURL)
        guard case .unmatched = links.resolve(path: "/no such page") else {
            Issue.record("a space in an in-app path is read as part of the segment")
            return
        }
    }
}

@Suite("Deep links: decoding and limits")
struct DeepLinkInputTests {
    @Test func anEncodedSlashStaysInsideOneSegment() throws {
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add("/files/:name") { match in match["name"] == "a/b" ? [.catalog] : nil }
        links.add("/files/:a/:b") { _ in [.settings] }
        #expect(entries(links.resolve(try url("shop://files/a%2Fb"))) == [.push(.catalog)])
        #expect(entries(links.resolve(try url("shop://files/a/b"))) == [.push(.settings)])
    }

    @Test(arguments: [
        "shop://account/%2e%2e/catalog",
        "shop://account/%2E/orders",
        "https://shop.example.com/products/../account/orders",
        "shop://account/./orders",
    ])
    func dotSegmentsAreRefusedNotResolved(text: String) throws {
        #expect(rejection(shopLinks().resolve(try url(text))) == .dotSegment)
    }

    @Test(arguments: ["shop://products/%C3", "shop://catalog?q=%E2%82", "shop://products/%FF%FE"])
    func percentEncodedBytesThatAreNotUTF8AreRefused(text: String) throws {
        #expect(rejection(shopLinks().resolve(try url(text))) == .invalidPercentEncoding)
    }

    @Test func aPercentSignWithoutHexDigitsIsReadLiterally() throws {
        // Foundation's URL parser encodes such a "%" as "%25", so the value arrives as written.
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add("/files/:name") { match in match["name"] == "%zz" ? [.catalog] : nil }
        #expect(entries(links.resolve(try url("shop://files/%zz"))) == [.push(.catalog)])
    }

    @Test(arguments: [
        "shop://products/1%00", "shop://products/%0A1", "shop://catalog?x=%E2%80%AE", "shop://catalog?%07=1",
        "shop://products/%C2%85",
    ])
    func controlCharactersAreRefused(text: String) throws {
        #expect(rejection(shopLinks().resolve(try url(text))) == .controlCharacter)
    }

    @Test func lengthLimitIsInclusive() throws {
        let limits = DeepLinkLimits(maxURLLength: 40)
        let base = "shop://catalog?q="
        let fits = base + String(repeating: "a", count: 40 - base.utf8.count)
        #expect(entries(shopLinks(limits: limits).resolve(try url(fits))) == [.push(.catalog)])
        #expect(rejection(shopLinks(limits: limits).resolve(try url(fits + "a"))) == .urlTooLong(limit: 40))
        #expect(rejection(shopLinks(limits: limits).resolve(path: "/" + String(repeating: "x", count: 40))) == .urlTooLong(limit: 40))
    }

    @Test func aHugeURLIsRefusedByLengthBeforeItIsSplit() throws {
        let path = Array(repeating: "a", count: 200_000).joined(separator: "/")
        #expect(rejection(shopLinks().resolve(try url("shop://x/" + path))) == .urlTooLong(limit: 2_048))
    }

    @Test func segmentAndQueryCountsAreBounded() throws {
        let limits = DeepLinkLimits(maxPathSegments: 3, maxQueryItems: 2)
        #expect(entries(shopLinks(limits: limits).resolve(try url("shop://products/1/reviews"))) != nil)
        #expect(rejection(shopLinks(limits: limits).resolve(try url("shop://products/1/reviews/x"))) == .tooManySegments(limit: 3))
        #expect(entries(shopLinks(limits: limits).resolve(try url("shop://catalog?a=1&b=2"))) != nil)
        #expect(rejection(shopLinks(limits: limits).resolve(try url("shop://catalog?a=1&b=2&c=3"))) == .tooManyQueryItems(limit: 2))
    }
}

@Suite("Deep links: typed values")
struct DeepLinkValueTests {
    private func match(_ text: String, pattern: String = "/v/:value") throws -> DeepLinkMatch {
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add(pattern) { _ in [.catalog] }
        guard case .matched(_, let match) = links.resolve(try url(text)) else {
            Issue.record("\(text) did not match")
            throw CancellationError()
        }
        return match
    }

    private enum Tab: String { case home, search }

    @Test func integersOutOfRangeOrWithJunkAreNil() throws {
        #expect(try match("shop://v/42").int("value") == 42)
        #expect(try match("shop://v/-7").int("value") == -7)
        #expect(try match("shop://v/99999999999999999999").int("value") == nil)
        #expect(try match("shop://v/4.5").int("value") == nil)
        #expect(try match("shop://v/12abc").int("value") == nil)
        #expect(try match("shop://v/%201").int("value") == nil)
        #expect(try match("shop://v/1").int("missing") == nil)
    }

    @Test(arguments: ["nan", "NaN", "inf", "-infinity", "1e999"])
    func nonFiniteDoublesAreNil(text: String) throws {
        #expect(try match("shop://v/\(text)").double("value") == nil)
        #expect(try match("shop://v/1?d=\(text)").queryDouble("d") == nil)
    }

    @Test func finiteDoublesUUIDsAndEnumsConvert() throws {
        #expect(try match("shop://v/2.5").double("value") == 2.5)
        let id = UUID()
        #expect(try match("shop://v/\(id.uuidString)").uuid("value") == id)
        #expect(try match("shop://v/not-a-uuid").uuid("value") == nil)
        #expect(try match("shop://v/search").value("value", as: Tab.self) == .search)
        #expect(try match("shop://v/Search").value("value", as: Tab.self) == nil)
        #expect(try match("shop://v/true").value("value", as: Bool.self) == true)
        #expect(try match("shop://v/300").value("value", as: UInt8.self) == nil)
    }

    @Test func queryItemsKeepOrderAndRepeatedNames() throws {
        let found = try match("shop://v/1?tag=a&tag=b%20c&flag&n=3&n=x")
        #expect(found.queryValues("tag") == ["a", "b c"])
        #expect(found.query("tag") == "a")
        #expect(found.query("flag") == "")
        #expect(found.queryInt("n") == 3)
        #expect(found.query("missing") == nil)
        #expect(found.queryItems.count == 5)
    }

    @Test func plusInAQueryIsKeptAsAPlus() throws {
        #expect(try match("shop://v/1?q=a+b").query("q") == "a+b")
    }

    @Test func wildcardRestIsDecoded() throws {
        #expect(try match("shop://docs/a%20b/c", pattern: "/docs/*").rest == ["a b", "c"])
    }

    @Test func pathsBuiltFromAPatternResolveToTheSameValues() throws {
        let values = ["plain", "with space", "slash/inside", "100%", "ünïcödé", "emoji 🧭", "a?b#c&d=e", "+plus"]
        let pattern = try URLPattern("/v/:value")
        for value in values {
            let path = try pattern.path(with: ["value": value])
            #expect(try match("shop:/" + path)["value"] == value, "\(value) did not survive \(path)")
        }
    }
}

@MainActor
@Suite("Deep links: opening in a router")
struct DeepLinkRouterTests {
    @Test func openingReplacesTheState() throws {
        let router = Router<TestRoute>(entries: [.sheet(.settings)])
        #expect(router.open(try url("shop://products/9"), using: shopLinks()) == .navigated(.applied))
        #expect(router.entries == [.push(.catalog), .push(.product(9))])
    }

    @Test func unmatchedAndRejectedLinksChangeNothing() throws {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        #expect(router.open(try url("shop://nowhere"), using: shopLinks()) == .unmatched)
        #expect(router.open(try url("https://evil.com/catalog"), using: shopLinks()) == .rejected(.hostNotAllowed))
        #expect(router.open(path: "/a/%2e%2e/b", using: shopLinks()) == .rejected(.dotSegment))
        #expect(router.entries == [.push(.catalog)])
    }

    @Test func aDeepLinkCannotSkipTheSignIn() throws {
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))

        #expect(router.open(try url("https://shop.example.com/account/orders"), using: shopLinks()) == .navigated(.redirected))
        #expect(router.entries == [.sheet(.signIn)])

        session.isSignedIn = true
        #expect(router.resumePending() == .applied)
        #expect(router.entries == [.push(.account), .push(.orders)])
    }

    @Test func aDeepLinkDeeperThanMaxDepthIsRejected() throws {
        let router = Router<TestRoute>(maxDepth: 2)
        #expect(router.open(try url("shop://products/1/reviews"), using: shopLinks()) == .navigated(.rejected(.depthLimitExceeded(limit: 2))))
        #expect(router.entries.isEmpty)
    }
}
