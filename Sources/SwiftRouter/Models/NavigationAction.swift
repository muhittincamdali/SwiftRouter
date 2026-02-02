// NavigationAction.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Navigation Action

/// Defines the type of navigation operation to perform.
///
/// ``NavigationAction`` represents every supported navigation primitive,
/// from simple push/pop to modal presentations and deep link handling.
///
/// ## Actions
///
/// | Action | Description |
/// |--------|-------------|
/// | `.push` | Push onto the navigation stack |
/// | `.present(style:)` | Present modally with a transition style |
/// | `.pop` | Pop the top entry |
/// | `.popToRoot` | Pop to the root entry |
/// | `.dismiss` | Dismiss the topmost modal |
/// | `.replace` | Replace the top entry |
/// | `.deepLink(url:)` | Navigate via a deep link URL |
public enum NavigationAction: Sendable {

    /// Push a route onto the navigation stack.
    case push

    /// Present a route modally with the specified transition style.
    case present(style: TransitionStyle)

    /// Pop the topmost route from the stack.
    case pop

    /// Pop all routes back to the root.
    case popToRoot

    /// Dismiss the topmost modal presentation.
    case dismiss

    /// Replace the topmost route with a new one.
    case replace

    /// Navigate via a deep link URL.
    case deepLink(url: URL)
}

// MARK: - Equatable

extension NavigationAction: Equatable {

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        switch (lhs, rhs) {
        case (.push, .push),
             (.pop, .pop),
             (.popToRoot, .popToRoot),
             (.dismiss, .dismiss),
             (.replace, .replace):
            return true
        case (.present(let lStyle), .present(let rStyle)):
            return lStyle == rStyle
        case (.deepLink(let lURL), .deepLink(let rURL)):
            return lURL == rURL
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension NavigationAction: CustomStringConvertible {

    public var description: String {
        switch self {
        case .push:
            return "push"
        case .present(let style):
            return "present(\(style))"
        case .pop:
            return "pop"
        case .popToRoot:
            return "popToRoot"
        case .dismiss:
            return "dismiss"
        case .replace:
            return "replace"
        case .deepLink(let url):
            return "deepLink(\(url))"
        }
    }
}

// MARK: - Navigation Action Builder

/// A builder for constructing complex navigation sequences.
///
/// ``NavigationSequence`` lets you chain multiple navigation actions
/// into a single, atomic operation.
///
/// ## Example
///
/// ```swift
/// let sequence = NavigationSequence {
///     NavigationStep(.popToRoot)
///     NavigationStep(.push, route: HomeRoute())
///     NavigationStep(.push, route: ProfileRoute(userId: "123"))
/// }
/// try await router.execute(sequence)
/// ```
public struct NavigationSequence: Sendable {

    /// The steps in this navigation sequence.
    public let steps: [NavigationStep]

    /// Whether the entire sequence should be animated.
    public let animated: Bool

    /// Creates a navigation sequence.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - steps: The navigation steps.
    public init(animated: Bool = true, steps: [NavigationStep]) {
        self.animated = animated
        self.steps = steps
    }

    /// Creates a navigation sequence using a result builder.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate.
    ///   - builder: The step builder closure.
    public init(animated: Bool = true, @NavigationSequenceBuilder builder: () -> [NavigationStep]) {
        self.animated = animated
        self.steps = builder()
    }
}

// MARK: - Navigation Step

/// A single step within a ``NavigationSequence``.
public struct NavigationStep: Sendable {

    /// The action to perform.
    public let action: NavigationAction

    /// The route for push/present/replace actions.
    public let route: (any Route)?

    /// Optional delay before executing this step (in seconds).
    public let delay: TimeInterval

    /// Creates a navigation step.
    ///
    /// - Parameters:
    ///   - action: The navigation action.
    ///   - route: The target route, if applicable.
    ///   - delay: Delay before execution. Defaults to `0`.
    public init(
        _ action: NavigationAction,
        route: (any Route)? = nil,
        delay: TimeInterval = 0
    ) {
        self.action = action
        self.route = route
        self.delay = delay
    }
}

// MARK: - Navigation Sequence Builder

/// A result builder for constructing ``NavigationSequence`` instances.
@resultBuilder
public struct NavigationSequenceBuilder {

    public static func buildBlock(_ components: NavigationStep...) -> [NavigationStep] {
        components
    }

    public static func buildOptional(_ component: [NavigationStep]?) -> [NavigationStep] {
        component ?? []
    }

    public static func buildEither(first component: [NavigationStep]) -> [NavigationStep] {
        component
    }

    public static func buildEither(second component: [NavigationStep]) -> [NavigationStep] {
        component
    }

    public static func buildArray(_ components: [[NavigationStep]]) -> [NavigationStep] {
        components.flatMap { $0 }
    }
}
