# Migrating from version 1

Move an app from SwiftRouter 1.0.0, or from SwiftUI-Navigation-Pro, to the typed router of 2.0.0.

## Overview

Version 2.0.0 replaces the API of 1.0.0. The 1.0.0 router looked routes up by string in a
registry, at run time; 2.0.0 is generic over your route enum, so the compiler checks every
destination. It needs iOS 17, macOS 14, tvOS 17, watchOS 10 or visionOS 1, and Swift 6.2.

| 1.0.0                                                               | 2.0.0                                                                        |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `Router` with a `RouteRegistry` and `register(_:)`                  | `Router<AppRoute>`; the enum lists the routes                                |
| `Route` structs with `RouteParameters`                              | `enum AppRoute: Route` with associated values                                |
| `navigate(to:)` (async, throwing)                                   | ``Router/push(_:)`` or ``Router/navigate(to:)``, returning a ``NavigationOutcome`` |
| `NavigationMiddleware`, `AuthMiddleware`                            | ``RouteGuard`` with ``Router/addGuard(_:)``                                      |
| `handleDeepLink(_:)` with `deepLinkScheme` and `universalLinkHosts` | ``DeepLinks`` with `schemes` and `hosts`, and ``Router/open(_:using:)``          |
| `RouterConfiguration.maxStackDepth`                                 | ``Router/maxDepth``                                                            |
| `RouterDelegate`, `navigationCompleted` publisher                   | Observe ``Router/entries``; the router is `@Observable`                        |
| `TransitionStyle`                                                   | ``PresentationStyle`` (`push`, `sheet`, `fullScreenCover`)                     |
| `isDebugLoggingEnabled`, `AnalyticsMiddleware`                      | Removed: the package does not log or collect events                          |

## Steps

1. Replace each registered route type with a case of one enum that conforms to ``Route``, and
   move the view each route showed into ``Route/view()``.
2. Replace `Router(configuration:)` with `@State private var router = Router<AppRoute>()` and
   wrap the root view in a ``RouterView``.
3. Turn each middleware that blocked navigation into a ``RouteGuard``. A middleware that
   redirected to a login screen becomes ``RouteGuard/requiring(_:for:otherwise:name:)``, and the
   login screen calls ``Router/resumePending()``.
4. Move each deep link route pattern into ``DeepLinks/add(_:_:)``. Path parameters are read with
   ``DeepLinkMatch/int(_:)`` and the other typed accessors instead of `RouteParameters`.
5. If you logged navigation through `AnalyticsMiddleware`, observe ``Router/entries`` in your
   app and record the routes you need. Leave URLs out of such records: links can carry tokens.

## Coming from SwiftUI-Navigation-Pro

SwiftUI-Navigation-Pro is archived and its navigation features now live in SwiftRouter. Its last
version with navigation code (commit `db5aac0`) does not build with Swift 6.4, so no file was
copied: each feature below was written again on top of ``Router``.

| SwiftUI-Navigation-Pro                                        | SwiftRouter 2.0.0                                                                                 |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `Router`, `Navigator`, `NavigationPathManager`                | ``Router`` shown by a ``RouterView``                                                              |
| `SheetPresenter` and its `PresentationStyle`                  | ``Router/present(_:style:)`` with ``PresentationStyle``; a sheet has its own stack                |
| Navigation guards of `NavigationPathManager`                  | ``RouteGuard`` with ``Router/addGuard(_:)``                                                       |
| `NavigationState`, `encodeState()`, `restoreState(from:)`    | ``RouterSnapshot``, ``Router/snapshotData()``, ``Router/restore(from:)``                          |
| `TabRouter`, `TabCoordinator`, `TabItem`                      | ``TabRouter`` with one router per tab                                                             |
| `DeepLinkParser`, `DeepLinkHandler`                           | ``DeepLinks``, ``URLPattern`` and ``SwiftUICore/View/onDeepLink(_:router:perform:)``              |
| `Coordinator`, `CoordinatorView`                              | A ``Router`` per flow in its own ``RouterView``, or a sheet whose stack holds the flow            |

These parts are not carried over:

- **`FlowCoordinator`, `FlowView`, `FlowProgressView`.** The step flow was a second state machine
  beside the router, kept step data as `Any` (so it could be neither saved nor checked by the
  compiler) and validated steps asynchronously, while SwiftRouter guards answer in the same
  update on purpose. Its 35 tests could not run, because that commit does not build. Make each
  step a route, push the next step with ``Router/push(_:)``, check a step with a ``RouteGuard``
  and keep the answers in your own model.
- **`NavigationHistory`.** A back and forward log beside the stack. ``Router/entries`` is the
  current state and the router is `@Observable`; observe it if you need your own log, and leave
  URLs out of it, because links can carry tokens.
- **`UIKitNavigationBridge` and its transition animators.** SwiftRouter is SwiftUI-only. Host a
  ``RouterView`` in a `UIHostingController` to use it in a UIKit app.
- **`SideMenuCoordinator`, `SideMenuContainer`.** A drawer view rather than routing. Build the
  menu in SwiftUI and call ``Router/setEntries(_:)`` or ``TabRouter/select(_:)`` from its items.
- **Hero and custom transitions, A/B testing, analytics, recording and crash recovery.** They were
  untested and are unrelated to routing.
