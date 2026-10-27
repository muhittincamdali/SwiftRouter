import Foundation
import Testing
@testable import SwiftRouter

/// Runs the README samples (ReadmeSamples.swift) so that what the README says they do is checked.
@MainActor
@Suite("README samples")
struct ReadmeSampleTests {
    @Test func theShopLinksMapBothURLForms() throws {
        let links = makeShopLinks()
        for text in ["shop://products/42", "https://shop.example.com/products/42"] {
            let router = Router<ShopRoute>()
            #expect(router.open(try #require(URL(string: text)), using: links) == .navigated(.applied))
            #expect(router.path == [.catalog, .product(id: 42)])
        }
        let router = Router<ShopRoute>()
        router.open(try #require(URL(string: "shop://cart")), using: links)
        #expect(router.entries == [.sheet(.cart)])
    }

    @Test func ordersNeedASignInAndOpenAfterIt() throws {
        let session = AccountSession()
        let router = Router<ShopRoute>()
        protectOrders(router, session: session)

        router.open(try #require(URL(string: "shop://orders")), using: makeShopLinks())
        #expect(router.entries == [.sheet(.signIn)])

        signIn(router, session: session)
        #expect(router.entries == [.push(.orders)])
    }

    @Test func signingInWithoutAPendingRequestClosesTheSheet() {
        let session = AccountSession()
        let router = Router<ShopRoute>(entries: [.push(.catalog), .sheet(.signIn)])
        signIn(router, session: session)
        #expect(router.entries == [.push(.catalog)])
    }
}
