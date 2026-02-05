//
//  BasicExample.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//
//  A complete example demonstrating SwiftRouter's core features.
//

import SwiftUI
import SwiftRouter

// MARK: - Route Definitions

/// Home screen route
struct HomeRoute: Route {
    static let pattern = "/home"
    
    var parameters: RouteParameters { [:] }
    
    init() {}
    init(parameters: RouteParameters) throws {}
}

/// User profile route with userId parameter
struct UserProfileRoute: Route {
    static let pattern = "/users/:userId"
    
    let userId: String
    
    var parameters: RouteParameters {
        ["userId": .string(userId)]
    }
    
    init(userId: String) {
        self.userId = userId
    }
    
    init(parameters: RouteParameters) throws {
        guard let userId = parameters.string(for: "userId") else {
            throw RouteError.missingParameter("userId")
        }
        self.userId = userId
    }
}

/// Settings route with optional section
struct SettingsRoute: Route {
    static let pattern = "/settings/:section?"
    
    let section: String?
    
    var parameters: RouteParameters {
        var params: [String: RouteParameterValue] = [:]
        if let section {
            params["section"] = .string(section)
        }
        return RouteParameters(params)
    }
    
    init(section: String? = nil) {
        self.section = section
    }
    
    init(parameters: RouteParameters) throws {
        self.section = parameters.string(for: "section")
    }
}

/// Product detail route with multiple parameters
struct ProductRoute: Route {
    static let pattern = "/products/:productId"
    
    let productId: String
    let variant: String?
    
    var parameters: RouteParameters {
        var params: [String: RouteParameterValue] = [
            "productId": .string(productId)
        ]
        if let variant {
            params["variant"] = .string(variant)
        }
        return RouteParameters(params)
    }
    
    init(productId: String, variant: String? = nil) {
        self.productId = productId
        self.variant = variant
    }
    
    init(parameters: RouteParameters) throws {
        guard let productId = parameters.string(for: "productId") else {
            throw RouteError.missingParameter("productId")
        }
        self.productId = productId
        self.variant = parameters.string(for: "variant")
    }
}

// MARK: - App Entry Point

/// Example app using SwiftRouter
struct SwiftRouterExampleApp: App {
    @StateObject private var router = Router(
        configuration: RouterConfiguration(
            isDebugLoggingEnabled: true,
            deepLinkScheme: "swiftrouterexample",
            universalLinkHosts: ["swiftrouter.example.com"]
        )
    )
    
    init() {
        setupRoutes()
        setupMiddleware()
    }
    
    var body: some Scene {
        WindowGroup {
            RouterView(router: router) { route in
                routeView(for: route)
            }
            .onOpenURL { url in
                Task {
                    try? await router.handleDeepLink(url)
                }
            }
        }
    }
    
    private func setupRoutes() {
        router.registry.register(HomeRoute.self)
        router.registry.register(UserProfileRoute.self)
        router.registry.register(SettingsRoute.self)
        router.registry.register(ProductRoute.self)
    }
    
    private func setupMiddleware() {
        // Add logging middleware
        router.use(ClosureMiddleware(name: "Logger") { context in
            print("📍 Navigating to: \(type(of: context.route).pattern)")
        })
    }
    
    @ViewBuilder
    private func routeView(for route: any Route) -> some View {
        switch route {
        case is HomeRoute:
            ExampleHomeView()
        case let route as UserProfileRoute:
            ExampleProfileView(userId: route.userId)
        case let route as SettingsRoute:
            ExampleSettingsView(section: route.section)
        case let route as ProductRoute:
            ExampleProductView(productId: route.productId, variant: route.variant)
        default:
            ExampleNotFoundView()
        }
    }
}

// MARK: - Views

struct ExampleHomeView: View {
    @Environment(\.router) private var router
    
    var body: some View {
        NavigationStack {
            List {
                Section("Navigation Examples") {
                    RouterLink("View Profile", to: UserProfileRoute(userId: "user123"))
                    
                    RouterLink(to: ProductRoute(productId: "prod456", variant: "blue")) {
                        Label("View Product", systemImage: "bag")
                    }
                }
                
                Section("Modal Examples") {
                    Button("Open Settings (Sheet)") {
                        Task {
                            try? await router?.navigate(
                                to: SettingsRoute(),
                                action: .present(style: .sheet)
                            )
                        }
                    }
                    
                    Button("Open Settings (Full Screen)") {
                        Task {
                            try? await router?.navigate(
                                to: SettingsRoute(section: "privacy"),
                                action: .present(style: .fullScreenCover)
                            )
                        }
                    }
                }
                
                Section("Deep Link Examples") {
                    Button("Simulate Deep Link") {
                        Task {
                            let url = URL(string: "swiftrouterexample://users/deeplink_user")!
                            try? await router?.handleDeepLink(url)
                        }
                    }
                }
            }
            .navigationTitle("SwiftRouter Demo")
        }
    }
}

struct ExampleProfileView: View {
    let userId: String
    
    @Environment(\.router) private var router
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("User Profile")
                .font(.title)
            
            Text("User ID: \(userId)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Divider()
            
            RouterLink("View Another User", to: UserProfileRoute(userId: "another_user"))
                .buttonStyle(.borderedProminent)
            
            RouterBackButton {
                Label("Go Back", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

struct ExampleSettingsView: View {
    let section: String?
    
    @Environment(\.router) private var router
    
    var body: some View {
        NavigationStack {
            List {
                if let section {
                    Section("Current Section") {
                        Text(section.capitalized)
                            .font(.headline)
                    }
                }
                
                Section("Settings") {
                    Label("General", systemImage: "gear")
                    Label("Privacy", systemImage: "lock")
                    Label("Notifications", systemImage: "bell")
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RouterDismissButton {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

struct ExampleProductView: View {
    let productId: String
    let variant: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Product Details")
                .font(.title)
            
            Text("Product ID: \(productId)")
                .font(.headline)
            
            if let variant {
                Text("Variant: \(variant)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Add to Cart") {
                // Add to cart action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Product")
    }
}

struct ExampleNotFoundView: View {
    var body: some View {
        VStack {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Page Not Found")
                .font(.title2)
        }
    }
}

// MARK: - Preview

#Preview {
    SwiftRouterExampleApp()
}
