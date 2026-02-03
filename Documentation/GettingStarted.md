# Getting Started with SwiftRouter

## Overview

SwiftRouter provides type-safe navigation for iOS applications with deep linking support.

## Installation

Add SwiftRouter to your project using Swift Package Manager.

## Basic Usage

### 1. Define Your Routes

```swift
enum AppRoute: Route {
    case home
    case profile(userId: String)
    case settings
}
```

### 2. Create Router

```swift
let router = Router<AppRoute>()
```

### 3. Navigate

```swift
await router.navigate(to: .profile(userId: "123"))
```

## Next Steps

- [Deep Linking Guide](DeepLinking.md)
- [SwiftUI Integration](SwiftUI.md)
- [UIKit Integration](UIKit.md)
