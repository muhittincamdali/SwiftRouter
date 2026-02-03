//
//  RouteLink.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import SwiftUI

// MARK: - Route Link Style

/// Style options for route links
public struct RouteLinkStyle: Sendable {
    
    /// Style type
    public enum StyleType: Sendable {
        case automatic
        case plain
        case bordered
        case borderedProminent
        case borderless
        case custom
    }
    
    /// Style type
    public let type: StyleType
    
    /// Foreground color
    public let foregroundColor: Color?
    
    /// Background color
    public let backgroundColor: Color?
    
    /// Corner radius
    public let cornerRadius: CGFloat
    
    /// Padding
    public let padding: EdgeInsets
    
    /// Font
    public let font: Font?
    
    /// Creates a style
    public init(
        type: StyleType = .automatic,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = 8,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
        font: Font? = nil
    ) {
        self.type = type
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.font = font
    }
    
    /// Default style
    public static let `default` = RouteLinkStyle()
    
    /// Plain style
    public static let plain = RouteLinkStyle(type: .plain)
    
    /// Bordered style
    public static let bordered = RouteLinkStyle(
        type: .bordered,
        foregroundColor: .accentColor,
        cornerRadius: 8
    )
    
    /// Prominent bordered style
    public static let borderedProminent = RouteLinkStyle(
        type: .borderedProminent,
        foregroundColor: .white,
        backgroundColor: .accentColor,
        cornerRadius: 8
    )
}

// MARK: - Route Link Configuration

/// Configuration for route links
public struct RouteLinkConfiguration: Sendable {
    
    /// Style
    public var style: RouteLinkStyle
    
    /// Whether to animate navigation
    public var animated: Bool
    
    /// Haptic feedback type
    public var hapticFeedback: HapticFeedbackType?
    
    /// Loading indicator type
    public var loadingIndicator: LoadingIndicatorType
    
    /// Whether link is enabled
    public var isEnabled: Bool
    
    /// Accessibility label override
    public var accessibilityLabel: String?
    
    /// Accessibility hint override
    public var accessibilityHint: String?
    
    /// Haptic feedback types
    public enum HapticFeedbackType: Sendable {
        case light
        case medium
        case heavy
        case selection
        case success
        case warning
        case error
    }
    
    /// Loading indicator types
    public enum LoadingIndicatorType: Sendable {
        case none
        case spinner
        case progress
        case custom
    }
    
    /// Creates configuration
    public init(
        style: RouteLinkStyle = .default,
        animated: Bool = true,
        hapticFeedback: HapticFeedbackType? = .selection,
        loadingIndicator: LoadingIndicatorType = .none,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil
    ) {
        self.style = style
        self.animated = animated
        self.hapticFeedback = hapticFeedback
        self.loadingIndicator = loadingIndicator
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
    /// Default configuration
    public static let `default` = RouteLinkConfiguration()
}

// MARK: - Route Link

/// A navigation link that integrates with SwiftRouter
public struct RouteLink<Label: View, Destination: Hashable>: View {
    
    // MARK: - Properties
    
    private let destination: Destination
    private let label: Label
    private let configuration: RouteLinkConfiguration
    private let onNavigate: ((Destination) -> Void)?
    
    @State private var isPressed = false
    @State private var isLoading = false
    
    // MARK: - Initialization
    
    /// Creates a route link with a destination and label
    /// - Parameters:
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - onNavigate: Optional navigation callback
    ///   - label: Label view builder
    public init(
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        onNavigate: ((Destination) -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.configuration = configuration
        self.onNavigate = onNavigate
        self.label = label()
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button {
            handleTap()
        } label: {
            labelContent
        }
        .buttonStyle(RouteLinkButtonStyle(
            style: configuration.style,
            isPressed: isPressed,
            isEnabled: configuration.isEnabled
        ))
        .disabled(!configuration.isEnabled || isLoading)
        .accessibilityLabel(configuration.accessibilityLabel ?? "Navigate")
        .accessibilityHint(configuration.accessibilityHint ?? "Double tap to navigate")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var labelContent: some View {
        HStack(spacing: 8) {
            if isLoading && configuration.loadingIndicator == .spinner {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
            }
            
            label
                .opacity(isLoading ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleTap() {
        guard configuration.isEnabled else { return }
        
        // Haptic feedback
        if let feedback = configuration.hapticFeedback {
            triggerHaptic(feedback)
        }
        
        // Navigation callback
        onNavigate?(destination)
    }
    
    private func triggerHaptic(_ type: RouteLinkConfiguration.HapticFeedbackType) {
        #if os(iOS)
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        #endif
    }
}

// MARK: - Convenience Initializers

public extension RouteLink where Label == Text {
    
    /// Creates a route link with a text label
    /// - Parameters:
    ///   - title: Link title
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - onNavigate: Optional navigation callback
    init(
        _ title: String,
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        onNavigate: ((Destination) -> Void)? = nil
    ) {
        self.destination = destination
        self.configuration = configuration
        self.onNavigate = onNavigate
        self.label = Text(title)
    }
    
    /// Creates a route link with a localized title
    /// - Parameters:
    ///   - titleKey: Localized string key
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - onNavigate: Optional navigation callback
    init(
        _ titleKey: LocalizedStringKey,
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        onNavigate: ((Destination) -> Void)? = nil
    ) {
        self.destination = destination
        self.configuration = configuration
        self.onNavigate = onNavigate
        self.label = Text(titleKey)
    }
}

public extension RouteLink where Label == SwiftUI.Label<Text, Image> {
    
    /// Creates a route link with an icon and title
    /// - Parameters:
    ///   - title: Link title
    ///   - systemImage: SF Symbol name
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - onNavigate: Optional navigation callback
    init(
        _ title: String,
        systemImage: String,
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        onNavigate: ((Destination) -> Void)? = nil
    ) {
        self.destination = destination
        self.configuration = configuration
        self.onNavigate = onNavigate
        self.label = SwiftUI.Label(title, systemImage: systemImage)
    }
}

// MARK: - Route Link Button Style

private struct RouteLinkButtonStyle: ButtonStyle {
    let style: RouteLinkStyle
    let isPressed: Bool
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(style.padding)
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .background(background(isPressed: configuration.isPressed))
            .font(style.font)
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func foregroundColor(isPressed: Bool) -> Color {
        if let color = style.foregroundColor {
            return isPressed ? color.opacity(0.8) : color
        }
        return .primary
    }
    
    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch style.type {
        case .automatic, .plain, .borderless:
            Color.clear
        case .bordered:
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.foregroundColor ?? .accentColor, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(isPressed ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        case .borderedProminent:
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(isPressed ? (style.backgroundColor ?? .accentColor).opacity(0.8) : (style.backgroundColor ?? .accentColor))
        case .custom:
            if let bgColor = style.backgroundColor {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(isPressed ? bgColor.opacity(0.8) : bgColor)
            } else {
                Color.clear
            }
        }
    }
}

// MARK: - Async Route Link

/// A route link that supports async navigation
public struct AsyncRouteLink<Label: View, Destination: Hashable>: View {
    
    private let destination: Destination
    private let label: Label
    private let configuration: RouteLinkConfiguration
    private let asyncAction: ((Destination) async throws -> Void)?
    
    @State private var isLoading = false
    @State private var error: Error?
    
    /// Creates an async route link
    /// - Parameters:
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - asyncAction: Async action to perform
    ///   - label: Label view builder
    public init(
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        asyncAction: ((Destination) async throws -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.configuration = configuration
        self.asyncAction = asyncAction
        self.label = label()
    }
    
    public var body: some View {
        Button {
            Task {
                await performNavigation()
            }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                }
                
                label
                    .opacity(isLoading ? 0.6 : 1.0)
            }
        }
        .buttonStyle(RouteLinkButtonStyle(
            style: configuration.style,
            isPressed: false,
            isEnabled: configuration.isEnabled && !isLoading
        ))
        .disabled(!configuration.isEnabled || isLoading)
    }
    
    private func performNavigation() async {
        guard let asyncAction = asyncAction else { return }
        
        isLoading = true
        error = nil
        
        do {
            try await asyncAction(destination)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - Conditional Route Link

/// A route link that can be conditionally enabled
public struct ConditionalRouteLink<Label: View, Destination: Hashable>: View {
    
    private let destination: Destination
    private let label: Label
    private let configuration: RouteLinkConfiguration
    private let condition: () -> Bool
    private let onNavigate: ((Destination) -> Void)?
    private let onDisabledTap: (() -> Void)?
    
    /// Creates a conditional route link
    /// - Parameters:
    ///   - destination: Navigation destination
    ///   - configuration: Link configuration
    ///   - condition: Condition closure
    ///   - onNavigate: Navigation callback
    ///   - onDisabledTap: Callback when tapped while disabled
    ///   - label: Label view builder
    public init(
        destination: Destination,
        configuration: RouteLinkConfiguration = .default,
        condition: @escaping () -> Bool,
        onNavigate: ((Destination) -> Void)? = nil,
        onDisabledTap: (() -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.configuration = configuration
        self.condition = condition
        self.onNavigate = onNavigate
        self.onDisabledTap = onDisabledTap
        self.label = label()
    }
    
    public var body: some View {
        Button {
            if condition() {
                onNavigate?(destination)
            } else {
                onDisabledTap?()
            }
        } label: {
            label
        }
        .buttonStyle(RouteLinkButtonStyle(
            style: configuration.style,
            isPressed: false,
            isEnabled: condition()
        ))
    }
}

// MARK: - Route Link Group

/// A group of route links with shared configuration
public struct RouteLinkGroup<Content: View>: View {
    
    private let configuration: RouteLinkConfiguration
    private let spacing: CGFloat
    private let content: Content
    
    /// Creates a route link group
    /// - Parameters:
    ///   - configuration: Shared configuration
    ///   - spacing: Spacing between links
    ///   - content: Content view builder
    public init(
        configuration: RouteLinkConfiguration = .default,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .environment(\.routeLinkConfiguration, configuration)
    }
}

// MARK: - Environment Key

private struct RouteLinkConfigurationKey: EnvironmentKey {
    static let defaultValue: RouteLinkConfiguration = .default
}

public extension EnvironmentValues {
    var routeLinkConfiguration: RouteLinkConfiguration {
        get { self[RouteLinkConfigurationKey.self] }
        set { self[RouteLinkConfigurationKey.self] = newValue }
    }
}

// MARK: - View Extensions

public extension View {
    
    /// Sets the route link style for this view
    func routeLinkStyle(_ style: RouteLinkStyle) -> some View {
        environment(\.routeLinkConfiguration, RouteLinkConfiguration(style: style))
    }
    
    /// Configures route links in this view
    func routeLinkConfiguration(_ configuration: RouteLinkConfiguration) -> some View {
        environment(\.routeLinkConfiguration, configuration)
    }
}
