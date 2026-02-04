<p align="center">
  <img src="Assets/logo.png" alt="SwiftRouter" width="200"/>
</p>

<h1 align="center">SwiftRouter</h1>

<p align="center">
  <strong>🧭 Type-safe deep linking & navigation router for iOS with async/await</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+"/>
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#deep-linking">Deep Linking</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## Why SwiftRouter?

Navigation in SwiftUI can get messy. Deep linking requires parsing URLs manually. State restoration is complex. **SwiftRouter** provides a declarative, type-safe solution.

```swift
// Before: Scattered navigation logic
NavigationLink(destination: UserView(id: userId)) { ... }
// Deep link parsing in AppDelegate
// State restoration in SceneDelegate

// After: Unified routing
router.navigate(to: .user(id: userId))
// Deep links handled automatically
// State restored automatically
```

## Features

| Feature | Description |
|---------|-------------|
| 🎯 **Type-Safe** | Compile-time route validation |
| 🔗 **Deep Linking** | Universal links & URL schemes |
| 💾 **State Restoration** | Automatic navigation state persistence |
| ⚡ **Async/Await** | Modern Swift concurrency |
| 🧪 **Testable** | Easy navigation testing |
| 📱 **SwiftUI Native** | Built for SwiftUI |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Routes

```swift
import SwiftRouter

enum AppRoute: Route {
    case home
    case user(id: String)
    case settings
    case product(id: String, color: String?)
    
    var path: String {
        switch self {
        case .home: return "/"
        case .user(let id): return "/user/\(id)"
        case .settings: return "/settings"
        case .product(let id, _): return "/product/\(id)"
        }
    }
}
```

### 2. Setup Router

```swift
@main
struct MyApp: App {
    @StateObject var router = Router<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            RouterView(router: router) { route in
                switch route {
                case .home:
                    HomeView()
                case .user(let id):
                    UserView(userId: id)
                case .settings:
                    SettingsView()
                case .product(let id, let color):
                    ProductView(id: id, color: color)
                }
            }
        }
    }
}
```

### 3. Navigate

```swift
struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            Button("View Profile") {
                router.push(.user(id: "123"))
            }
            
            Button("Settings") {
                router.push(.settings)
            }
        }
    }
}
```

## Navigation Methods

### Push

```swift
router.push(.user(id: "123"))
```

### Pop

```swift
router.pop()
router.popToRoot()
router.pop(to: .home)
```

### Replace

```swift
router.replace(with: .home)
```

### Present (Modal)

```swift
router.present(.settings, style: .sheet)
router.present(.login, style: .fullScreen)
```

### Dismiss

```swift
router.dismiss()
```

## Deep Linking

### URL Scheme

```swift
// myapp://user/123
extension AppRoute {
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let pathComponents = components.path.split(separator: "/")
        
        switch pathComponents.first {
        case "user":
            guard let id = pathComponents.dropFirst().first else { return nil }
            self = .user(id: String(id))
        case "settings":
            self = .settings
        default:
            return nil
        }
    }
}
```

### Universal Links

```swift
// Handle in App
@main
struct MyApp: App {
    @StateObject var router = Router<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            RouterView(router: router) { ... }
                .onOpenURL { url in
                    if let route = AppRoute(url: url) {
                        router.handle(route)
                    }
                }
        }
    }
}
```

### apple-app-site-association

```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAM_ID.com.myapp",
      "paths": ["/user/*", "/product/*", "/settings"]
    }]
  }
}
```

## State Restoration

Automatically save and restore navigation state:

```swift
let router = Router<AppRoute>(
    persistence: .userDefaults,
    key: "navigation_state"
)

// State is automatically saved on navigation changes
// and restored on app launch
```

## Tab Navigation

```swift
struct MainView: View {
    @StateObject var homeRouter = Router<HomeRoute>()
    @StateObject var profileRouter = Router<ProfileRoute>()
    
    var body: some View {
        TabView {
            RouterView(router: homeRouter) { ... }
                .tabItem { Label("Home", systemImage: "house") }
            
            RouterView(router: profileRouter) { ... }
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
```

## Middleware

Add custom logic before navigation:

```swift
router.addMiddleware { route, action in
    // Analytics
    Analytics.track("navigate_to_\(route.path)")
    
    // Auth check
    if route.requiresAuth && !isLoggedIn {
        return .redirect(to: .login)
    }
    
    return .continue
}
```

## Async Navigation

```swift
Button("Load & Navigate") {
    Task {
        let user = try await api.fetchUser(id: "123")
        await router.push(.user(id: user.id))
    }
}
```

## Testing

```swift
class NavigationTests: XCTestCase {
    func testUserNavigation() {
        let router = Router<AppRoute>()
        
        router.push(.user(id: "123"))
        
        XCTAssertEqual(router.currentRoute, .user(id: "123"))
        XCTAssertEqual(router.stack.count, 2)
    }
    
    func testDeepLink() {
        let router = Router<AppRoute>()
        let url = URL(string: "myapp://user/456")!
        
        router.handle(url: url)
        
        XCTAssertEqual(router.currentRoute, .user(id: "456"))
    }
}
```

## Best Practices

### Route Organization

```swift
// ✅ Good: Grouped by feature
enum AppRoute: Route {
    case home
    case auth(AuthRoute)
    case profile(ProfileRoute)
    case settings(SettingsRoute)
}

enum AuthRoute: Route {
    case login
    case register
    case forgotPassword
}
```

### Type-Safe Parameters

```swift
// ✅ Good: Strong types
case user(id: User.ID)
case product(id: Product.ID, variant: Product.Variant)

// ❌ Avoid: Raw strings
case user(id: String)
```

## API Reference

### Router

```swift
class Router<R: Route>: ObservableObject {
    var currentRoute: R
    var stack: [R]
    
    func push(_ route: R)
    func pop()
    func popToRoot()
    func replace(with route: R)
    func present(_ route: R, style: PresentationStyle)
    func dismiss()
    func handle(url: URL)
}
```

### Route Protocol

```swift
protocol Route: Hashable, Codable {
    var path: String { get }
    init?(url: URL)
}
```

## Examples

See [Examples](Examples/):
- **BasicNavigation** - Simple push/pop
- **DeepLinking** - URL handling
- **TabBar** - Multi-router tabs
- **Authentication** - Protected routes

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

<p align="center">
  <sub>Navigate with confidence 🧭</sub>
</p>

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/SwiftRouter&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftRouter&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftRouter&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/SwiftRouter&type=Date" />
 </picture>
</a>
