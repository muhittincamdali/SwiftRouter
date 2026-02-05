# Getting Started with SwiftRouter

This guide will help you integrate SwiftRouter into your iOS application.

## Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SwiftRouter to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

## Basic Setup

### Step 1: Define Your Routes

Create route types that conform to the `Route` protocol:

```swift
import SwiftRouter

struct HomeRoute: Route {
    static let pattern = "/home"
    
    var parameters: RouteParameters { [:] }
    
    init(parameters: RouteParameters) throws {}
}

struct ProfileRoute: Route {
    static let pattern = "/profile/:userId"
    
    let userId: String
    
    var parameters: RouteParameters {
        ["userId": .string(userId)]
    }
    
    init(parameters: RouteParameters) throws {
        guard let userId = parameters.string(for: "userId") else {
            throw RouteError.missingParameter("userId")
        }
        self.userId = userId
    }
}
```

### Step 2: Configure the Router

Create and configure your router in your app's entry point:

```swift
import SwiftUI
import SwiftRouter

@main
struct MyApp: App {
    @StateObject private var router = Router(
        configuration: RouterConfiguration(
            deepLinkScheme: "myapp",
            universalLinkHosts: ["example.com"],
            isDebugLoggingEnabled: true
        )
    )
    
    init() {
        // Register routes
        router.registry.register(HomeRoute.self)
        router.registry.register(ProfileRoute.self)
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
    
    @ViewBuilder
    private func routeView(for route: any Route) -> some View {
        switch route {
        case is HomeRoute:
            HomeView()
        case let route as ProfileRoute:
            ProfileView(userId: route.userId)
        default:
            Text("Not Found")
        }
    }
}
```

### Step 3: Navigate

Use the router from your views:

```swift
struct HomeView: View {
    @Environment(\.router) private var router
    
    var body: some View {
        VStack {
            Text("Welcome!")
            
            // Using RouterLink
            RouterLink(to: ProfileRoute(userId: "123")) {
                Text("View Profile")
            }
            
            // Using Button with Task
            Button("Open Settings") {
                Task {
                    try? await router?.navigate(
                        to: SettingsRoute(),
                        action: .present(style: .sheet)
                    )
                }
            }
        }
    }
}
```

## Navigation Actions

SwiftRouter supports various navigation actions:

```swift
// Push (default)
try await router.navigate(to: route)
try await router.navigate(to: route, action: .push)

// Present modal
try await router.navigate(to: route, action: .present(style: .sheet))
try await router.navigate(to: route, action: .present(style: .fullScreenCover))

// Pop
router.pop()
router.popToRoot()

// Dismiss modal
router.dismiss()

// Replace current route
try await router.navigate(to: route, action: .replace)
```

## Deep Linking

SwiftRouter automatically handles deep links if routes are properly registered:

```swift
// URL: myapp://profile/123
// Automatically resolves to ProfileRoute(userId: "123")
```

Handle incoming URLs:

```swift
.onOpenURL { url in
    Task {
        try? await router.handleDeepLink(url)
    }
}
```

## What's Next?

- Learn about [Middleware](Middleware.md) for auth and analytics
- Explore [Coordinator Pattern](Coordinators.md) for complex flows
- Check out [Tab Navigation](TabNavigation.md) for multi-tab apps
- Read about [Testing](Testing.md) your navigation
