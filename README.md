<div align="center">

# 🧭 SwiftRouter

**Type-safe deep linking & navigation router for iOS with async/await support**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/muhittincamdali/SwiftRouter/ci.yml?style=for-the-badge&logo=github)](https://github.com/muhittincamdali/SwiftRouter/actions)

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation)

</div>

---

## ✨ Features

- 🔗 **Type-Safe Routing** — Compile-time checked routes with associated values
- 🌊 **Deep Linking** — Handle any URL scheme with automatic parameter extraction
- ⚡ **Async/Await** — Modern Swift concurrency support throughout
- 🎯 **Universal Links** — Full support for iOS Universal Links
- 📱 **SwiftUI & UIKit** — Works with both frameworks seamlessly
- 🔄 **State Restoration** — Automatic navigation state persistence
- 🧪 **Testable** — Designed for easy unit testing with mock support
- 📦 **Zero Dependencies** — Pure Swift implementation

---

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → Enter URL

---

## 🚀 Quick Start

### Define Routes

```swift
import SwiftRouter

enum AppRoute: Route {
    case home
    case profile(userId: String)
    case settings
    case product(id: Int, variant: String?)
    
    var path: String {
        switch self {
        case .home: return "/"
        case .profile(let userId): return "/profile/\(userId)"
        case .settings: return "/settings"
        case .product(let id, let variant): 
            return "/product/\(id)" + (variant.map { "?variant=\($0)" } ?? "")
        }
    }
}
```

### Setup Router

```swift
let router = Router<AppRoute>()

// Register route handlers
router.register(.home) { route in
    HomeView()
}

router.register(.profile) { route in
    if case .profile(let userId) = route {
        ProfileView(userId: userId)
    }
}
```

### Navigate

```swift
// Programmatic navigation
await router.navigate(to: .profile(userId: "123"))

// Deep link handling
router.handle(url: URL(string: "myapp://profile/123")!)

// With animation
await router.navigate(to: .settings, animated: true)
```

### SwiftUI Integration

```swift
struct ContentView: View {
    @StateObject var router = Router<AppRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    router.view(for: route)
                }
        }
        .environmentObject(router)
    }
}
```

---

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| [Getting Started](Documentation/GettingStarted.md) | Step-by-step guide |
| [Deep Linking](Documentation/DeepLinking.md) | URL handling |
| [State Restoration](Documentation/StateRestoration.md) | Persistence |
| [API Reference](Documentation/API.md) | Full API docs |

---

## 🛠 Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| tvOS | 15.0+ |
| watchOS | 8.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Muhittin Camdali** • [@muhittincamdali](https://github.com/muhittincamdali)

---

<p align="center">Made with ❤️ in Istanbul</p>
