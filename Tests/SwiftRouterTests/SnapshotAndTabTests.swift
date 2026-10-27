import Foundation
import Testing
@testable import SwiftRouter

@MainActor
@Suite("Saving and restoring the state")
struct SnapshotTests {
    @Test func aSnapshotRestoresTheSameEntries() throws {
        let original = Router<TestRoute>(entries: [.push(.catalog), .push(.product(4)), .sheet(.settings), .fullScreenCover(.signIn)])
        let data = try original.snapshotData()
        let restored = Router<TestRoute>()
        #expect(try restored.restore(from: data) == .applied)
        #expect(restored.entries == original.entries)
    }

    @Test func theSnapshotFormatIsVersionedJSON() throws {
        let data = try Router<TestRoute>(entries: [.push(.catalog)]).snapshotData()
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["version"] as? Int == 1)
        #expect((object["entries"] as? [Any])?.count == 1)
    }

    @Test func restoredScreensGoThroughTheGuards() throws {
        let data = try Router<TestRoute>(entries: [.push(.catalog), .push(.account)]).snapshotData()
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        #expect(try router.restore(from: data) == .redirected)
        #expect(router.entries == [.push(.catalog), .sheet(.signIn)])
    }

    @Test func aSnapshotDeeperThanMaxDepthIsRejected() throws {
        let data = try Router<TestRoute>(entries: [.push(.catalog), .push(.product(1)), .push(.reviews(1))]).snapshotData()
        let router = Router<TestRoute>(entries: [.push(.settings)], maxDepth: 2)
        #expect(try router.restore(from: data) == .rejected(.depthLimitExceeded(limit: 2)))
        #expect(router.entries == [.push(.settings)])
    }

    @Test(arguments: [
        Data(), Data("not json".utf8), Data(#"{"version":1,"entries":[{"route":{"unknown":{}},"style":"push"}]}"#.utf8),
        Data(#"{"version":1,"entries":[{"route":{"catalog":{}},"style":"sideways"}]}"#.utf8),
        Data(#"{"version":1}"#.utf8),
    ])
    func unreadableDataLeavesTheStateAlone(data: Data) {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        #expect(throws: RestorationError.unreadable) { try router.restore(from: data) }
        #expect(router.entries == [.push(.catalog)])
    }

    @Test func otherFormatVersionsAreRefused() {
        let data = Data(#"{"version":2,"entries":[]}"#.utf8)
        #expect(throws: RestorationError.unsupportedVersion(2)) { try Router<TestRoute>().restore(from: data) }
    }

    @Test func dataOverTheSizeLimitIsRefusedBeforeDecoding() {
        let limit = Router<TestRoute>.maxSnapshotSize
        let data = Data(repeating: UInt8(ascii: " "), count: limit + 1)
        #expect(throws: RestorationError.tooLarge(limit: limit)) { try Router<TestRoute>().restore(from: data) }
    }
}

@MainActor
@Suite("Tab router")
struct TabRouterTests {
    enum Tab: Hashable { case shop, account, more }

    @Test func eachTabKeepsItsOwnStack() {
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account])
        #expect(tabs.selection == .shop)
        tabs.router(for: .shop).push(.catalog)
        tabs.select(.account)
        tabs.selectedRouter.push(.settings)
        #expect(tabs.router(for: .shop).path == [.catalog])
        #expect(tabs.router(for: .account).path == [.settings])
    }

    @Test func choosingTheSelectedTabAgainPopsToItsRoot() {
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account], selection: .account)
        tabs.selectedRouter.push(contentsOf: [.account, .orders])
        tabs.selectionBinding.wrappedValue = .account
        #expect(tabs.selectedRouter.path.isEmpty)
    }

    @Test func reselectingCanBeTurnedOff() {
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop])
        tabs.popsToRootOnReselect = false
        tabs.selectedRouter.push(.catalog)
        tabs.select(.shop)
        #expect(tabs.selectedRouter.path == [.catalog])
    }

    @Test func switchingTabsDoesNotPop() {
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account])
        tabs.selectedRouter.push(.catalog)
        tabs.select(.account)
        tabs.select(.shop)
        #expect(tabs.router(for: .shop).path == [.catalog])
    }

    @Test func aURLOpensInTheFirstTabThatMatches() throws {
        var shopLinks = DeepLinks<TestRoute>(schemes: ["shop"])
        shopLinks.add("/products/:id") { match in match.int("id").map { [.catalog, .product($0)] } }
        var accountLinks = DeepLinks<TestRoute>(schemes: ["shop"])
        accountLinks.add("/orders") { _ in [.account, .orders] }
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account, .more])

        let url = try #require(URL(string: "shop://orders"))
        #expect(tabs.open(url, using: [.shop: shopLinks, .account: accountLinks]) == .navigated(.applied))
        #expect(tabs.selection == .account)
        #expect(tabs.router(for: .account).path == [.account, .orders])
        #expect(tabs.router(for: .shop).path.isEmpty)
    }

    @Test func aURLNoTabMatchesLeavesTheSelectionAlone() throws {
        var links = DeepLinks<TestRoute>(schemes: ["shop"])
        links.add("/catalog") { _ in [.catalog] }
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account], selection: .account)

        #expect(tabs.open(try #require(URL(string: "shop://nowhere")), using: [.shop: links]) == .unmatched)
        #expect(tabs.open(try #require(URL(string: "other://catalog")), using: [.shop: links]) == .rejected(.unsupportedScheme))
        #expect(tabs.selection == .account)
    }

    @Test func aGuardAddedToTheTabsChecksEveryTab() {
        let session = Session()
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account])
        tabs.addGuard(.account(session))
        #expect(tabs.router(for: .shop).push(.orders) == .redirected)
        #expect(tabs.router(for: .account).push(.account) == .redirected)
    }

    @Test func everyTabUsesTheMaxDepth() {
        let tabs = TabRouter<Tab, TestRoute>(tabs: [.shop, .account], maxDepth: 3)
        #expect(tabs.tabs.allSatisfy { tabs.router(for: $0).maxDepth == 3 })
    }
}
