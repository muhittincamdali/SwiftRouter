import SwiftUI
import SwiftRouter

// MARK: - Route Definition

enum AppRoute: Route, Hashable {
    case home
    case profile(userId: String)
    case settings
    case product(id: Int)
    
    var path: String {
        switch self {
        case .home: return "/"
        case .profile(let userId): return "/profile/\(userId)"
        case .settings: return "/settings"
        case .product(let id): return "/product/\(id)"
        }
    }
}

// MARK: - Router Setup

@MainActor
class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var router = AppRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .profile(let userId):
            ProfileView(userId: userId)
        case .settings:
            SettingsView()
        case .product(let id):
            ProductView(productId: id)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        List {
            Button("Go to Profile") {
                router.navigate(to: .profile(userId: "user123"))
            }
            
            Button("Go to Settings") {
                router.navigate(to: .settings)
            }
            
            Button("View Product") {
                router.navigate(to: .product(id: 42))
            }
        }
        .navigationTitle("Home")
    }
}

struct ProfileView: View {
    let userId: String
    
    var body: some View {
        Text("Profile: \(userId)")
            .navigationTitle("Profile")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

struct ProductView: View {
    let productId: Int
    
    var body: some View {
        Text("Product #\(productId)")
            .navigationTitle("Product")
    }
}
