# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- watchOS full support
- visionOS support
- SwiftData persistence option
- Navigation transition customization API

---

## [1.0.0] - 2025-02-05

### Added

#### Core
- **Router** - Central navigation coordinator with async/await support
- **Route Protocol** - Type-safe route definitions with compile-time validation
- **RouteRegistry** - Pattern-based route registration and resolution
- **NavigationStack** - Full push/pop/present/dismiss management
- **PathMatcher** - URL pattern matching with parameters, optionals, and wildcards
- **RouterConfiguration** - Flexible router configuration options

#### Deep Linking
- **DeepLinkHandler** - Custom URL scheme handling (`myapp://`)
- **UniversalLinkHandler** - Apple App Site Association (AASA) support
- Automatic parameter extraction from URLs
- Query parameter support
- Fragment identifier support

#### Middleware
- **NavigationMiddleware Protocol** - Extensible middleware system
- **AuthMiddleware** - Built-in authentication guards with:
  - Role-based access control
  - Permission system
  - Rate limiting
  - Session management
  - Auto-refresh support
- **AnalyticsMiddleware** - Navigation tracking with:
  - Screen view tracking
  - Timing metrics
  - Event batching
  - Offline persistence
  - Sampling support
- **ClosureMiddleware** - Quick inline middleware
- **ConditionalMiddleware** - Conditional middleware execution

#### SwiftUI Integration
- **RouterView** - Drop-in NavigationStack replacement
- **RouterLink** - Type-safe navigation links
- **RouterBackButton** - Custom back button
- **RouterDismissButton** - Modal dismiss button
- **RouterPopToRootButton** - Pop to root action
- Environment injection via `@Environment(\.router)`

#### UIKit Integration
- **UIKitRouter** - UINavigationController bridge
- **ViewControllerFactory** - Route-to-ViewController mapping
- Custom transition delegate support
- Full push/pop/present/dismiss parity

#### Tab Navigation
- **TabRouter** - Multi-tab navigation management
- **TabItem** - Tab configuration with badges
- Independent navigation stacks per tab
- Badge management (count, dot, text)
- Tab visibility and enabled state
- Double-tap to pop-to-root
- State persistence

#### Split View
- **SplitViewRouter** - iPad split view support
- Two-column and three-column layouts
- Sidebar, content, and detail management
- Adaptive compact behavior
- State persistence

#### Coordinator Pattern
- **Coordinator Protocol** - Flow management
- **AppCoordinator** - Root coordinator base class
- **TabCoordinator** - Tab-based coordinator
- Child coordinator management
- Lifecycle events

#### Models
- **NavigationAction** - Push, pop, present, dismiss, replace, deep link
- **TransitionStyle** - Sheet, fullscreen, fade, slide, zoom, custom
- **RouteParameters** - Type-safe parameter container
- **RouteParameterValue** - String, int, double, bool, UUID, date, array

#### Testing
- Comprehensive unit tests
- Router mock support
- Navigation assertion helpers

### Security
- Input validation on all route parameters
- URL sanitization in deep link handling
- Rate limiting in auth middleware

---

## [0.9.0] - 2025-01-20 (Beta)

### Added
- Initial beta release
- Core routing functionality
- Basic SwiftUI support

### Changed
- Refined API based on beta feedback

### Fixed
- Memory leaks in navigation stack
- Thread safety issues in middleware chain

---

## Version History

| Version | Release Date | Swift | iOS | Status |
|---------|-------------|-------|-----|--------|
| 1.0.0 | 2025-02-05 | 5.9+ | 15+ | **Current** |
| 0.9.0 | 2025-01-20 | 5.9+ | 15+ | Beta |

---

[Unreleased]: https://github.com/muhittincamdali/SwiftRouter/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/muhittincamdali/SwiftRouter/releases/tag/v1.0.0
[0.9.0]: https://github.com/muhittincamdali/SwiftRouter/releases/tag/v0.9.0
