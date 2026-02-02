// TransitionStyle.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Transition Style

/// Defines the visual transition style for navigation operations.
///
/// ``TransitionStyle`` covers both push-based and modal presentation
/// styles, allowing fine-grained control over navigation animations.
///
/// ## Built-in Styles
///
/// | Style | Description |
/// |-------|-------------|
/// | `.push` | Standard navigation push (left-to-right) |
/// | `.sheet` | Bottom sheet presentation |
/// | `.fullScreenCover` | Full-screen modal presentation |
/// | `.fade` | Cross-fade transition |
/// | `.slide` | Slide from a specified edge |
/// | `.custom` | Custom transition with identifier |
public enum TransitionStyle: Sendable, Equatable, CustomStringConvertible {

    /// Standard navigation push transition.
    case push

    /// Bottom sheet modal presentation.
    case sheet

    /// Full-screen cover presentation.
    case fullScreenCover

    /// Cross-fade transition.
    case fade

    /// Slide transition from the specified edge.
    case slide(edge: SlideEdge)

    /// Zoom transition with a specified scale factor.
    case zoom(scale: Double)

    /// No animation.
    case none

    /// A custom transition identified by a string key.
    ///
    /// Use this to map to your own custom UIKit or SwiftUI transitions.
    case custom(identifier: String)

    // MARK: - Properties

    /// Whether this style represents a modal presentation.
    public var isModal: Bool {
        switch self {
        case .sheet, .fullScreenCover:
            return true
        default:
            return false
        }
    }

    /// Whether this style should animate.
    public var isAnimated: Bool {
        if case .none = self { return false }
        return true
    }

    /// The default animation duration in seconds.
    public var defaultDuration: TimeInterval {
        switch self {
        case .push: return 0.35
        case .sheet: return 0.3
        case .fullScreenCover: return 0.3
        case .fade: return 0.25
        case .slide: return 0.3
        case .zoom: return 0.3
        case .none: return 0
        case .custom: return 0.3
        }
    }

    public var description: String {
        switch self {
        case .push: return "push"
        case .sheet: return "sheet"
        case .fullScreenCover: return "fullScreenCover"
        case .fade: return "fade"
        case .slide(let edge): return "slide(\(edge))"
        case .zoom(let scale): return "zoom(\(scale))"
        case .none: return "none"
        case .custom(let id): return "custom(\(id))"
        }
    }
}

// MARK: - Slide Edge

/// The edge from which a slide transition originates.
public enum SlideEdge: String, Sendable, Equatable {

    /// Slide from the top edge.
    case top

    /// Slide from the bottom edge.
    case bottom

    /// Slide from the leading (left in LTR) edge.
    case leading

    /// Slide from the trailing (right in LTR) edge.
    case trailing
}

// MARK: - Transition Configuration

/// Extended configuration for a transition, including timing and interactivity.
public struct TransitionConfiguration: Sendable, Equatable {

    /// The transition style.
    public let style: TransitionStyle

    /// Animation duration in seconds.
    public let duration: TimeInterval

    /// Whether the transition is interactive (supports gestures).
    public let isInteractive: Bool

    /// The animation curve type.
    public let curve: AnimationCurve

    /// Creates a transition configuration.
    ///
    /// - Parameters:
    ///   - style: The transition style.
    ///   - duration: Duration in seconds. Defaults to the style's default.
    ///   - isInteractive: Whether interactive. Defaults to `false`.
    ///   - curve: The animation curve. Defaults to `.easeInOut`.
    public init(
        style: TransitionStyle,
        duration: TimeInterval? = nil,
        isInteractive: Bool = false,
        curve: AnimationCurve = .easeInOut
    ) {
        self.style = style
        self.duration = duration ?? style.defaultDuration
        self.isInteractive = isInteractive
        self.curve = curve
    }
}

// MARK: - Animation Curve

/// The timing curve for transition animations.
public enum AnimationCurve: String, Sendable, Equatable {

    /// Linear animation (constant speed).
    case linear

    /// Ease-in animation (starts slow).
    case easeIn

    /// Ease-out animation (ends slow).
    case easeOut

    /// Ease-in-out animation (starts and ends slow).
    case easeInOut

    /// Spring animation with default parameters.
    case spring
}
