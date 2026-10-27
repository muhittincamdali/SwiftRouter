import SwiftRouter
import SwiftUI

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let symbol: String
    let price: Decimal
    let reviews: [String]

    static let catalog: [Product] = [
        Product(id: 1, name: "Trail Compass", symbol: "safari", price: 24, reviews: ["Points north every time.", "Light and solid."]),
        Product(id: 2, name: "Pocket Map", symbol: "map", price: 12, reviews: ["Folds back the right way.", "Waterproof, as promised.", "Clear print."]),
        Product(id: 3, name: "Head Lamp", symbol: "flashlight.on.fill", price: 35, reviews: ["Bright on the lowest setting."]),
    ]

    static func existing(_ id: Int) -> Product? { catalog.first { $0.id == id } }
    static func find(_ id: Int) -> Product { existing(id) ?? catalog[0] }
}

struct CatalogScreen: View {
    var body: some View {
        List(Product.catalog) { product in
            RouterLink(to: AppRoute.product(id: product.id)) {
                Label(product.name, systemImage: product.symbol)
            }
            .accessibilityIdentifier("product-\(product.id)")
        }
        .navigationTitle("Shop")
        .toolbar {
            RouterLink(to: AppRoute.cart, style: .sheet) {
                Label("Cart", systemImage: "cart")
            }
            .accessibilityIdentifier("open-cart")
        }
    }
}

struct ProductScreen: View {
    let product: Product
    @Environment(Router<AppRoute>.self) private var router

    var body: some View {
        List {
            Section {
                Label(product.name, systemImage: product.symbol)
                    .font(.title2)
                LabeledContent("Price", value: product.price, format: .currency(code: "USD"))
            }
            Section {
                RouterLink("Reviews (\(String(product.reviews.count)))", to: AppRoute.reviews(productID: product.id))
                    .accessibilityIdentifier("open-reviews")
                Button("Add to cart and open it") { router.present(.cart) }
                    .accessibilityIdentifier("add-to-cart")
            }
            if let link = DemoLinks.url(for: product) {
                Section("Deep link") {
                    Text(link.absoluteString)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle(product.name)
    }
}

struct ReviewsScreen: View {
    let product: Product

    var body: some View {
        List(product.reviews, id: \.self) { review in
            Label(review, systemImage: "star.fill")
        }
        .navigationTitle("Reviews")
        .accessibilityIdentifier("reviews-list")
    }
}

struct CartScreen: View {
    @Environment(Router<AppRoute>.self) private var router

    var body: some View {
        List {
            Section("In your cart") {
                Label("Pocket Map", systemImage: "map")
                Label("Head Lamp", systemImage: "flashlight.on.fill")
            }
            Section {
                RouterLink("See my orders", to: AppRoute.orders)
                    .accessibilityIdentifier("cart-orders")
            } footer: {
                Text("Orders need an account: while you are signed out, the router shows the sign-in sheet first.")
            }
        }
        .navigationTitle("Cart")
        .toolbar {
            Button("Close") { router.dismiss() }
                .accessibilityIdentifier("close-cart")
        }
    }
}

struct SignInScreen: View {
    @Environment(Session.self) private var session
    @Environment(Router<AppRoute>.self) private var router
    @State private var name = "Ada"

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
            } footer: {
                Text("After you sign in, the screen you asked for opens.")
            }
            Button("Sign in") {
                session.userName = name
                if router.resumePending() == nil { router.dismiss() }
            }
            .accessibilityIdentifier("sign-in")
        }
        .navigationTitle("Sign in")
        .toolbar {
            Button("Cancel") {
                router.discardPending()
                router.dismiss()
            }
        }
    }
}

struct AccountScreen: View {
    let signOut: () -> Void
    @Environment(Session.self) private var session

    var body: some View {
        List {
            Section {
                if let name = session.userName {
                    Label("Signed in as \(name)", systemImage: "person.crop.circle.badge.checkmark")
                } else {
                    Label("Signed out", systemImage: "person.crop.circle.badge.xmark")
                }
            }
            Section {
                RouterLink("Orders", to: AppRoute.orders)
                    .accessibilityIdentifier("account-orders")
                RouterLink("Settings", to: AppRoute.settings)
                if session.isSignedIn {
                    Button("Sign out", role: .destructive, action: signOut)
                        .accessibilityIdentifier("sign-out")
                } else {
                    RouterLink("Sign in", to: AppRoute.signIn, style: .sheet)
                }
            }
        }
        .navigationTitle("Account")
    }
}

struct OrdersScreen: View {
    var body: some View {
        List([1001, 1002], id: \.self) { id in
            RouterLink(to: AppRoute.order(id: id)) {
                Label("Order \(String(id))", systemImage: "shippingbox")
            }
        }
        .navigationTitle("Orders")
        .accessibilityIdentifier("orders-list")
    }
}

struct OrderScreen: View {
    let id: Int

    var body: some View {
        List {
            LabeledContent("Order", value: String(id))
            LabeledContent("Status", value: "Shipped")
        }
        .navigationTitle("Order \(String(id))")
    }
}

struct SettingsScreen: View {
    @Environment(Router<AppRoute>.self) private var router

    var body: some View {
        List {
            Section {
                LabeledContent("Screens in this tab", value: String(router.entries.count))
                Button("Back to the first screen") { router.reset() }
            } footer: {
                Text("This tab's stack is saved in the scene and comes back after the system ends the app.")
            }
        }
        .navigationTitle("Settings")
    }
}
