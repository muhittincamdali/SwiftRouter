# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-27

Version 2.0.0 is a new router with a new API. In June 2026 the 1.0.0 sources were replaced with
placeholder code; this release replaces that code and takes over the presentation, tab and
state-saving features of SwiftUI-Navigation-Pro, which is being archived. The
[migration guide](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
maps the 1.0.0 API to the new one.

### Added

- `Route` protocol for an enum of screens, `RouteEntry` and `PresentationStyle` (`push`, `sheet`,
  `fullScreenCover`).
- `Router`, an `@Observable` main-actor class that holds the whole navigation state:
  `push`, `push(contentsOf:)`, `present(_:style:)`, `setEntries`, `pop`, `popToRoot`, `popTo`,
  `dismiss`, `dismissAll` and `reset`, with a `maxDepth` limit (64 by default).
- `RouterView`, which shows the state with one `NavigationStack` per level, so a sheet has its own
  stack and can present another sheet. The back button, the swipe back, a swipe down on a sheet
  and `NavigationLink(value:)` update the router. macOS shows full-screen covers as sheets.
- `RouterLink`, a button that pushes or presents a route.
- `RouteGuard` with `allow`, `cancel` and `redirect`, `requiring(_:for:otherwise:name:)`,
  `pending`, `resumePending()`, `discardPending()` and `revalidate()`. Guards check every entry
  added by code, deep links, restored snapshots and `NavigationLink`.
- `DeepLinks` and `URLPattern`: custom-scheme and universal links mapped to whole navigation
  states, patterns with `:name`, `:name?` and `*` tried from the most specific, typed values in
  `DeepLinkMatch`, `path(with:rest:)` to build links, `Router.open(_:using:)`,
  `open(path:using:)` and the `onDeepLink(_:router:perform:)` modifier.
- `TabRouter` with one router per tab, `popsToRootOnReselect`, `selectionBinding`, guards for every
  tab and `open(_:using:)` per tab.
- `RouterSnapshot`, `snapshotData()`, `restore(from:)` and the
  `routerStateRestoration(_:key:)` modifier, which keeps the state in the scene's storage.
- DocC documentation with five articles, and the RouterDemo example app for iOS and macOS with
  UI tests.

### Changed

- **Breaking:** the package needs Swift 6.2 and iOS 17, macOS 14, tvOS 17, watchOS 10 or
  visionOS 1.
- **Breaking:** the 1.0.0 string registry (`Router`, `RouteRegistry`, `RouteParameters`),
  middleware (`NavigationMiddleware`, `AuthMiddleware`, `AnalyticsMiddleware`), `TransitionStyle`,
  `RouterConfiguration`, `RouterDelegate` and the UIKit router are replaced by the API above.

### Removed

- The CocoaPods podspec. It was never published (the name belongs to another pod on the trunk);
  use Swift Package Manager.
- The placeholder `CircuitBreaker`, `RetryPolicy`, `EventBus`, `MetricsCollector` and
  `ErrorHandler` types and the `SwiftRouter.version` constant from the June 2026 code.
- Debug logging. The package does not print or log URLs, routes or events.

### Security

- Deep links are checked before any pattern runs: URL length, segment and query item limits,
  `https` only on listed hosts written as plain DNS names (never percent-decoded) on port 443, no
  user names or passwords, no `.` or `..` segments (also percent-encoded), no control or
  bidirectional formatting characters and no invalid UTF-8.
  Typed values are `nil` for out-of-range integers, `nan` and `inf` instead of trapping.
- The June 2026 `UniversalLinkParser` printed every incoming URL to the console, which wrote
  tokens carried by links into the device log. It is removed.
- Restored snapshots are limited to 256 KiB and `maxDepth` entries and go through the guards.

## [1.0.0] - 2026-02-03

### Added

- First release: a router with a string-based route registry, a deep link handler for a custom
  scheme and universal link hosts, navigation middleware for authentication and analytics, a
  coordinator, SwiftUI views and a UIKit router.

[Unreleased]: https://github.com/muhittincamdali/SwiftRouter/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/SwiftRouter/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/SwiftRouter/releases/tag/v1.0.0
