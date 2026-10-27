import SwiftRouter
import SwiftUI

/// Every screen of the demo shop.
enum AppRoute: Route, Codable {
    case product(id: Int)
    case reviews(productID: Int)
    case cart
    case orders
    case order(id: Int)
    case signIn
    case settings

    /// Screens that only a signed-in user may see.
    var needsAccount: Bool {
        switch self {
        case .orders, .order: true
        default: false
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .product(let id): ProductScreen(product: Product.find(id))
        case .reviews(let id): ReviewsScreen(product: Product.find(id))
        case .cart: CartScreen()
        case .orders: OrdersScreen()
        case .order(let id): OrderScreen(id: id)
        case .signIn: SignInScreen()
        case .settings: SettingsScreen()
        }
    }
}

/// The tabs of the demo.
enum DemoTab: String, Hashable, CaseIterable {
    case shop, account
}

/// The deep links of each tab: `routerdemo://products/2/reviews`, `routerdemo://cart`,
/// `routerdemo://account/orders/1001` and the others below.
enum DemoLinks {
    static let scheme = "routerdemo"

    static let shop: DeepLinks<AppRoute> = {
        var links = DeepLinks<AppRoute>(schemes: [scheme])
        links.add("/products/:id") { match in
            match.int("id").flatMap(Product.existing).map { [.product(id: $0.id)] }
        }
        links.add("/products/:id/reviews") { match in
            match.int("id").flatMap(Product.existing).map { [.product(id: $0.id), .reviews(productID: $0.id)] }
        }
        links.add("/cart", entries: { _ in [.sheet(.cart)] })
        return links
    }()

    static let account: DeepLinks<AppRoute> = {
        var links = DeepLinks<AppRoute>(schemes: [scheme])
        links.add("/account/orders") { _ in [.orders] }
        links.add("/account/orders/:id") { match in match.int("id").map { [.orders, .order(id: $0)] } }
        links.add("/account/settings") { _ in [.settings] }
        return links
    }()

    /// The link that opens a product, built from the same pattern the app matches.
    static func url(for product: Product) -> URL? {
        guard let path = try? URLPattern("/products/:id").path(with: ["id": String(product.id)]) else { return nil }
        return URL(string: scheme + ":/" + path)
    }
}

/// The signed-in state the account guard reads.
@MainActor
@Observable
final class Session {
    var userName: String?
    var isSignedIn: Bool { userName != nil }
}

/// The app's state: the session and one router per tab, with the account guard on every tab.
@MainActor
final class AppModel {
    let session = Session()
    let tabs = TabRouter<DemoTab, AppRoute>(tabs: DemoTab.allCases)

    init() {
        let session = session
        tabs.addGuard(.requiring(
            { session.isSignedIn },
            for: { $0.needsAccount },
            otherwise: [.sheet(.signIn)],
            name: "account"
        ))
    }

    func open(_ url: URL) {
        tabs.open(url, using: [.shop: DemoLinks.shop, .account: DemoLinks.account])
    }

    func signOut() {
        session.userName = nil
        for tab in tabs.tabs { tabs.router(for: tab).revalidate() }
    }
}
