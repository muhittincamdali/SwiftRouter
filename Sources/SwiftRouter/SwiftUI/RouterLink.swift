// RouterLink.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Router Link

/// A SwiftUI view that navigates to a route when tapped.
///
/// ``RouterLink`` is a drop-in replacement for `NavigationLink` that
/// uses the ``Router`` for navigation instead of SwiftUI's built-in
/// navigation system.
///
/// ## Usage
///
/// ```swift
/// RouterLink(to: ProfileRoute(userId: "42")) {
///     Label("View Profile", systemImage: "person")
/// }
///
/// RouterLink("Settings", to: SettingsRoute())
/// ```
public struct RouterLink<Label: View>: View {

    /// The target route.
    private let route: any Route

    /// The navigation action.
    private let action: NavigationAction

    /// Whether to animate the transition.
    private let animated: Bool

    /// The label view.
    private let label: Label

    /// Router from environment.
    @Environment(\.router) private var router

    /// Creates a router link with a custom label.
    ///
    /// - Parameters:
    ///   - route: The destination route.
    ///   - action: Navigation action. Defaults to `.push`.
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - label: The label view builder.
    public init(
        to route: any Route,
        action: NavigationAction = .push,
        animated: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.route = route
        self.action = action
        self.animated = animated
        self.label = label()
    }

    public var body: some View {
        Button {
            Task {
                try? await router?.navigate(to: route, action: action, animated: animated)
            }
        } label: {
            label
        }
    }
}

// MARK: - Text Convenience

public extension RouterLink where Label == Text {

    /// Creates a router link with a text label.
    ///
    /// - Parameters:
    ///   - title: The text label.
    ///   - route: The destination route.
    ///   - action: Navigation action. Defaults to `.push`.
    ///   - animated: Whether to animate. Defaults to `true`.
    init(
        _ title: String,
        to route: any Route,
        action: NavigationAction = .push,
        animated: Bool = true
    ) {
        self.route = route
        self.action = action
        self.animated = animated
        self.label = Text(title)
    }
}

// MARK: - Router Back Button

/// A button that pops the current route from the navigation stack.
///
/// Use ``RouterBackButton`` as a custom back button in your navigation bar
/// or anywhere you need a "go back" action.
public struct RouterBackButton<Label: View>: View {

    private let label: Label

    @Environment(\.router) private var router

    /// Creates a back button with a custom label.
    ///
    /// - Parameter label: The label view builder.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        Button {
            router?.pop()
        } label: {
            label
        }
    }
}

public extension RouterBackButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a back button with the default chevron icon.
    init() {
        self.label = SwiftUI.Label("Back", systemImage: "chevron.left")
    }
}

// MARK: - Router Dismiss Button

/// A button that dismisses the current modal presentation.
public struct RouterDismissButton<Label: View>: View {

    private let label: Label

    @Environment(\.router) private var router

    /// Creates a dismiss button with a custom label.
    ///
    /// - Parameter label: The label view builder.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        Button {
            router?.dismiss()
        } label: {
            label
        }
    }
}

public extension RouterDismissButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a dismiss button with the default X icon.
    init() {
        self.label = SwiftUI.Label("Close", systemImage: "xmark")
    }
}

// MARK: - Router Pop To Root Button

/// A button that pops to the root of the navigation stack.
public struct RouterPopToRootButton<Label: View>: View {

    private let label: Label

    @Environment(\.router) private var router

    /// Creates a pop-to-root button with a custom label.
    ///
    /// - Parameter label: The label view builder.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        Button {
            router?.popToRoot()
        } label: {
            label
        }
    }
}
#endif
