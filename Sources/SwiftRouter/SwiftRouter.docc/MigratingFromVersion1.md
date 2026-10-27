# Migrating from version 1

Move an app from SwiftRouter 1.0.0 to the typed router of 2.0.0.

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
