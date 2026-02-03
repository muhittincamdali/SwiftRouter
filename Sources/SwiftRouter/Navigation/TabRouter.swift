//
//  TabRouter.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Tab Item

/// Represents a single tab in the tab router
public struct TabItem: Identifiable, Hashable, Sendable {
    
    /// Unique identifier
    public let id: String
    
    /// Tab title
    public let title: String
    
    /// System image name
    public let systemImage: String
    
    /// Custom image name (optional)
    public let customImage: String?
    
    /// Badge value
    public var badge: TabBadge?
    
    /// Tab accessibility label
    public let accessibilityLabel: String
    
    /// Tab accessibility hint
    public let accessibilityHint: String
    
    /// Whether the tab is enabled
    public var isEnabled: Bool
    
    /// Associated route identifier
    public let routeIdentifier: String
    
    /// Tab order priority
    public let order: Int
    
    /// Tab visibility
    public var isVisible: Bool
    
    /// Creates a new tab item
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Tab title
    ///   - systemImage: SF Symbol name
    ///   - customImage: Custom image name
    ///   - badge: Badge configuration
    ///   - accessibilityLabel: Accessibility label
    ///   - accessibilityHint: Accessibility hint
    ///   - isEnabled: Enabled state
    ///   - routeIdentifier: Route identifier
    ///   - order: Display order
    ///   - isVisible: Visibility state
    public init(
        id: String,
        title: String,
        systemImage: String,
        customImage: String? = nil,
        badge: TabBadge? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        isEnabled: Bool = true,
        routeIdentifier: String,
        order: Int = 0,
        isVisible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.customImage = customImage
        self.badge = badge
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint ?? "Double tap to select \(title)"
        self.isEnabled = isEnabled
        self.routeIdentifier = routeIdentifier
        self.order = order
        self.isVisible = isVisible
    }
}

// MARK: - Tab Badge

/// Configuration for a tab badge
public struct TabBadge: Hashable, Sendable {
    
    /// Badge type
    public enum BadgeType: Hashable, Sendable {
        case count(Int)
        case text(String)
        case dot
        case custom(String)
    }
    
    /// Badge content
    public let type: BadgeType
    
    /// Badge color
    public let color: BadgeColor
    
    /// Badge visibility
    public var isVisible: Bool
    
    /// Badge color options
    public enum BadgeColor: Hashable, Sendable {
        case red
        case blue
        case green
        case orange
        case custom(red: Double, green: Double, blue: Double)
    }
    
    /// Creates a count badge
    /// - Parameters:
    ///   - count: Badge count
    ///   - color: Badge color
    public static func count(_ count: Int, color: BadgeColor = .red) -> TabBadge {
        TabBadge(type: .count(count), color: color, isVisible: count > 0)
    }
    
    /// Creates a text badge
    /// - Parameters:
    ///   - text: Badge text
    ///   - color: Badge color
    public static func text(_ text: String, color: BadgeColor = .red) -> TabBadge {
        TabBadge(type: .text(text), color: color, isVisible: !text.isEmpty)
    }
    
    /// Creates a dot badge
    /// - Parameter color: Badge color
    public static func dot(color: BadgeColor = .red) -> TabBadge {
        TabBadge(type: .dot, color: color, isVisible: true)
    }
    
    /// Creates a tab badge
    public init(type: BadgeType, color: BadgeColor = .red, isVisible: Bool = true) {
        self.type = type
        self.color = color
        self.isVisible = isVisible
    }
    
    /// String representation for SwiftUI
    public var stringValue: String? {
        guard isVisible else { return nil }
        
        switch type {
        case .count(let count):
            return count > 99 ? "99+" : "\(count)"
        case .text(let text):
            return text
        case .dot:
            return "●"
        case .custom(let value):
            return value
        }
    }
}

// MARK: - Tab Router State

/// State of the tab router
public struct TabRouterState: Equatable, Sendable {
    
    /// Selected tab ID
    public var selectedTabId: String
    
    /// Navigation stacks per tab
    public var navigationStacks: [String: [String]]
    
    /// Tab visibility states
    public var tabVisibility: [String: Bool]
    
    /// Tab enabled states
    public var tabEnabled: [String: Bool]
    
    /// Badge states
    public var badges: [String: TabBadge]
    
    /// Creates initial state
    public init(
        selectedTabId: String,
        navigationStacks: [String: [String]] = [:],
        tabVisibility: [String: Bool] = [:],
        tabEnabled: [String: Bool] = [:],
        badges: [String: TabBadge] = [:]
    ) {
        self.selectedTabId = selectedTabId
        self.navigationStacks = navigationStacks
        self.tabVisibility = tabVisibility
        self.tabEnabled = tabEnabled
        self.badges = badges
    }
}

// MARK: - Tab Navigation Event

/// Events that occur during tab navigation
public enum TabNavigationEvent: Equatable, Sendable {
    case tabSelected(tabId: String, previousId: String)
    case tabReselected(tabId: String)
    case tabBadgeUpdated(tabId: String, badge: TabBadge?)
    case tabVisibilityChanged(tabId: String, isVisible: Bool)
    case tabEnabledChanged(tabId: String, isEnabled: Bool)
    case navigationStackChanged(tabId: String, stack: [String])
    case deepLinkHandled(tabId: String, route: String)
}

// MARK: - Tab Router Error

/// Errors during tab routing
public enum TabRouterError: Error, LocalizedError, Sendable {
    case tabNotFound(String)
    case tabDisabled(String)
    case tabHidden(String)
    case invalidConfiguration
    case navigationFailed(String)
    case stateRestoreFailed
    
    public var errorDescription: String? {
        switch self {
        case .tabNotFound(let id):
            return "Tab not found: \(id)"
        case .tabDisabled(let id):
            return "Tab is disabled: \(id)"
        case .tabHidden(let id):
            return "Tab is hidden: \(id)"
        case .invalidConfiguration:
            return "Invalid tab router configuration"
        case .navigationFailed(let reason):
            return "Navigation failed: \(reason)"
        case .stateRestoreFailed:
            return "Failed to restore tab state"
        }
    }
}

// MARK: - Tab Router Protocol

/// Protocol for tab router implementations
public protocol TabRouterProtocol: AnyObject {
    
    /// Selected tab ID
    var selectedTabId: String { get }
    
    /// All registered tabs
    var tabs: [TabItem] { get }
    
    /// Visible tabs
    var visibleTabs: [TabItem] { get }
    
    /// Selects a tab by ID
    func selectTab(_ id: String) throws
    
    /// Updates a tab's badge
    func updateBadge(_ badge: TabBadge?, for tabId: String)
    
    /// Shows or hides a tab
    func setTabVisibility(_ isVisible: Bool, for tabId: String)
    
    /// Enables or disables a tab
    func setTabEnabled(_ isEnabled: Bool, for tabId: String)
}

// MARK: - Tab Router

/// Main tab router implementation
@MainActor
public final class TabRouter: ObservableObject, TabRouterProtocol {
    
    // MARK: - Published Properties
    
    /// Currently selected tab ID
    @Published public private(set) var selectedTabId: String
    
    /// All tabs
    @Published public private(set) var tabs: [TabItem]
    
    /// Current state
    @Published public private(set) var state: TabRouterState
    
    /// Last navigation event
    @Published public private(set) var lastEvent: TabNavigationEvent?
    
    /// Last error
    @Published public private(set) var lastError: TabRouterError?
    
    // MARK: - Computed Properties
    
    /// Visible and sorted tabs
    public var visibleTabs: [TabItem] {
        tabs.filter { $0.isVisible }.sorted { $0.order < $1.order }
    }
    
    /// Enabled tabs
    public var enabledTabs: [TabItem] {
        tabs.filter { $0.isEnabled }
    }
    
    /// Currently selected tab
    public var selectedTab: TabItem? {
        tabs.first { $0.id == selectedTabId }
    }
    
    // MARK: - Private Properties
    
    private var navigationStacks: [String: [String]] = [:]
    private var tabChangeHandlers: [(TabNavigationEvent) -> Void] = []
    private var cancellables = Set<AnyCancellable>()
    private let configuration: Configuration
    private var historyStack: [String] = []
    private let maxHistorySize: Int = 50
    
    // MARK: - Configuration
    
    /// Tab router configuration
    public struct Configuration {
        
        /// Whether to persist state
        public var persistState: Bool
        
        /// State persistence key
        public var persistenceKey: String
        
        /// Whether to animate tab changes
        public var animateChanges: Bool
        
        /// Whether double-tap resets navigation
        public var doubleTapResetsNavigation: Bool
        
        /// Whether to track history
        public var trackHistory: Bool
        
        /// Default tab ID
        public var defaultTabId: String?
        
        /// Tab change debounce interval
        public var debounceInterval: TimeInterval
        
        /// Creates a configuration
        public init(
            persistState: Bool = true,
            persistenceKey: String = "TabRouterState",
            animateChanges: Bool = true,
            doubleTapResetsNavigation: Bool = true,
            trackHistory: Bool = true,
            defaultTabId: String? = nil,
            debounceInterval: TimeInterval = 0.1
        ) {
            self.persistState = persistState
            self.persistenceKey = persistenceKey
            self.animateChanges = animateChanges
            self.doubleTapResetsNavigation = doubleTapResetsNavigation
            self.trackHistory = trackHistory
            self.defaultTabId = defaultTabId
            self.debounceInterval = debounceInterval
        }
        
        public static let `default` = Configuration()
    }
    
    // MARK: - Initialization
    
    /// Creates a tab router
    /// - Parameters:
    ///   - tabs: Initial tabs
    ///   - initialTabId: Initially selected tab
    ///   - configuration: Router configuration
    public init(
        tabs: [TabItem],
        initialTabId: String? = nil,
        configuration: Configuration = .default
    ) {
        self.configuration = configuration
        self.tabs = tabs.sorted { $0.order < $1.order }
        
        let defaultId = initialTabId ?? configuration.defaultTabId ?? tabs.first?.id ?? ""
        self.selectedTabId = defaultId
        self.state = TabRouterState(selectedTabId: defaultId)
        
        // Initialize navigation stacks
        for tab in tabs {
            navigationStacks[tab.id] = [tab.routeIdentifier]
        }
        
        // Restore state if enabled
        if configuration.persistState {
            restoreState()
        }
        
        setupBindings()
    }
    
    // MARK: - Tab Selection
    
    /// Selects a tab by ID
    /// - Parameter id: Tab ID to select
    public func selectTab(_ id: String) throws {
        guard let tab = tabs.first(where: { $0.id == id }) else {
            throw TabRouterError.tabNotFound(id)
        }
        
        guard tab.isVisible else {
            throw TabRouterError.tabHidden(id)
        }
        
        guard tab.isEnabled else {
            throw TabRouterError.tabDisabled(id)
        }
        
        let previousId = selectedTabId
        
        if previousId == id {
            // Tab reselected
            handleTabReselection(tab)
        } else {
            // Tab changed
            selectedTabId = id
            state.selectedTabId = id
            
            if configuration.trackHistory {
                addToHistory(id)
            }
            
            let event = TabNavigationEvent.tabSelected(tabId: id, previousId: previousId)
            lastEvent = event
            notifyHandlers(event)
            
            if configuration.persistState {
                saveState()
            }
        }
    }
    
    /// Selects the next tab
    /// - Returns: True if selection changed
    @discardableResult
    public func selectNextTab() -> Bool {
        let visible = visibleTabs.filter { $0.isEnabled }
        guard let currentIndex = visible.firstIndex(where: { $0.id == selectedTabId }) else {
            return false
        }
        
        let nextIndex = (currentIndex + 1) % visible.count
        let nextTab = visible[nextIndex]
        
        do {
            try selectTab(nextTab.id)
            return true
        } catch {
            return false
        }
    }
    
    /// Selects the previous tab
    /// - Returns: True if selection changed
    @discardableResult
    public func selectPreviousTab() -> Bool {
        let visible = visibleTabs.filter { $0.isEnabled }
        guard let currentIndex = visible.firstIndex(where: { $0.id == selectedTabId }) else {
            return false
        }
        
        let prevIndex = currentIndex > 0 ? currentIndex - 1 : visible.count - 1
        let prevTab = visible[prevIndex]
        
        do {
            try selectTab(prevTab.id)
            return true
        } catch {
            return false
        }
    }
    
    /// Goes back in tab history
    /// - Returns: True if went back
    @discardableResult
    public func goBack() -> Bool {
        guard historyStack.count > 1 else { return false }
        
        historyStack.removeLast()
        if let previousId = historyStack.last {
            do {
                // Temporarily disable history tracking
                let wasTracking = configuration.trackHistory
                try selectTab(previousId)
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
    // MARK: - Tab Management
    
    /// Registers a new tab
    /// - Parameter tab: Tab to register
    public func registerTab(_ tab: TabItem) {
        guard !tabs.contains(where: { $0.id == tab.id }) else { return }
        
        tabs.append(tab)
        tabs.sort { $0.order < $1.order }
        navigationStacks[tab.id] = [tab.routeIdentifier]
    }
    
    /// Unregisters a tab
    /// - Parameter id: Tab ID to remove
    public func unregisterTab(_ id: String) {
        tabs.removeAll { $0.id == id }
        navigationStacks.removeValue(forKey: id)
        
        // Select another tab if current was removed
        if selectedTabId == id, let first = visibleTabs.first {
            try? selectTab(first.id)
        }
    }
    
    /// Updates a tab
    /// - Parameter tab: Updated tab
    public func updateTab(_ tab: TabItem) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        tabs[index] = tab
    }
    
    // MARK: - Badge Management
    
    /// Updates a tab's badge
    /// - Parameters:
    ///   - badge: New badge (nil to remove)
    ///   - tabId: Tab ID
    public func updateBadge(_ badge: TabBadge?, for tabId: String) {
        guard let index = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        
        tabs[index].badge = badge
        state.badges[tabId] = badge
        
        let event = TabNavigationEvent.tabBadgeUpdated(tabId: tabId, badge: badge)
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Increments a tab's badge count
    /// - Parameters:
    ///   - tabId: Tab ID
    ///   - amount: Amount to increment
    public func incrementBadge(for tabId: String, by amount: Int = 1) {
        guard let index = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        
        let currentCount: Int
        if let badge = tabs[index].badge, case .count(let count) = badge.type {
            currentCount = count
        } else {
            currentCount = 0
        }
        
        let newBadge = TabBadge.count(currentCount + amount)
        updateBadge(newBadge, for: tabId)
    }
    
    /// Clears a tab's badge
    /// - Parameter tabId: Tab ID
    public func clearBadge(for tabId: String) {
        updateBadge(nil, for: tabId)
    }
    
    /// Clears all badges
    public func clearAllBadges() {
        for tab in tabs {
            clearBadge(for: tab.id)
        }
    }
    
    // MARK: - Visibility Management
    
    /// Sets tab visibility
    /// - Parameters:
    ///   - isVisible: Visibility state
    ///   - tabId: Tab ID
    public func setTabVisibility(_ isVisible: Bool, for tabId: String) {
        guard let index = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        
        tabs[index].isVisible = isVisible
        state.tabVisibility[tabId] = isVisible
        
        let event = TabNavigationEvent.tabVisibilityChanged(tabId: tabId, isVisible: isVisible)
        lastEvent = event
        notifyHandlers(event)
        
        // Select another tab if current became hidden
        if !isVisible && selectedTabId == tabId {
            if let first = visibleTabs.filter({ $0.isEnabled }).first {
                try? selectTab(first.id)
            }
        }
    }
    
    /// Sets tab enabled state
    /// - Parameters:
    ///   - isEnabled: Enabled state
    ///   - tabId: Tab ID
    public func setTabEnabled(_ isEnabled: Bool, for tabId: String) {
        guard let index = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        
        tabs[index].isEnabled = isEnabled
        state.tabEnabled[tabId] = isEnabled
        
        let event = TabNavigationEvent.tabEnabledChanged(tabId: tabId, isEnabled: isEnabled)
        lastEvent = event
        notifyHandlers(event)
        
        // Select another tab if current became disabled
        if !isEnabled && selectedTabId == tabId {
            if let first = visibleTabs.filter({ $0.isEnabled }).first {
                try? selectTab(first.id)
            }
        }
    }
    
    // MARK: - Navigation Stack Management
    
    /// Gets the navigation stack for a tab
    /// - Parameter tabId: Tab ID
    /// - Returns: Navigation stack
    public func getNavigationStack(for tabId: String) -> [String] {
        navigationStacks[tabId] ?? []
    }
    
    /// Pushes a route onto a tab's navigation stack
    /// - Parameters:
    ///   - route: Route to push
    ///   - tabId: Tab ID
    public func pushRoute(_ route: String, to tabId: String) {
        var stack = navigationStacks[tabId] ?? []
        stack.append(route)
        navigationStacks[tabId] = stack
        state.navigationStacks[tabId] = stack
        
        let event = TabNavigationEvent.navigationStackChanged(tabId: tabId, stack: stack)
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Pops a route from a tab's navigation stack
    /// - Parameter tabId: Tab ID
    /// - Returns: Popped route
    @discardableResult
    public func popRoute(from tabId: String) -> String? {
        var stack = navigationStacks[tabId] ?? []
        guard stack.count > 1 else { return nil }
        
        let popped = stack.removeLast()
        navigationStacks[tabId] = stack
        state.navigationStacks[tabId] = stack
        
        let event = TabNavigationEvent.navigationStackChanged(tabId: tabId, stack: stack)
        lastEvent = event
        notifyHandlers(event)
        
        return popped
    }
    
    /// Pops to root for a tab
    /// - Parameter tabId: Tab ID
    public func popToRoot(for tabId: String) {
        guard let root = navigationStacks[tabId]?.first else { return }
        
        navigationStacks[tabId] = [root]
        state.navigationStacks[tabId] = [root]
        
        let event = TabNavigationEvent.navigationStackChanged(tabId: tabId, stack: [root])
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Pops to root for all tabs
    public func popToRootAll() {
        for tabId in navigationStacks.keys {
            popToRoot(for: tabId)
        }
    }
    
    // MARK: - Event Handling
    
    /// Adds a tab change handler
    /// - Parameter handler: Handler closure
    public func onTabChange(_ handler: @escaping (TabNavigationEvent) -> Void) {
        tabChangeHandlers.append(handler)
    }
    
    // MARK: - State Management
    
    /// Saves current state
    public func saveState() {
        guard configuration.persistState else { return }
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(CodableState(state: state)) {
            UserDefaults.standard.set(data, forKey: configuration.persistenceKey)
        }
    }
    
    /// Restores saved state
    public func restoreState() {
        guard configuration.persistState else { return }
        
        guard let data = UserDefaults.standard.data(forKey: configuration.persistenceKey) else {
            return
        }
        
        let decoder = JSONDecoder()
        if let codableState = try? decoder.decode(CodableState.self, from: data) {
            self.state = codableState.toState()
            self.selectedTabId = state.selectedTabId
            
            // Restore visibility and enabled states
            for (tabId, isVisible) in state.tabVisibility {
                if let index = tabs.firstIndex(where: { $0.id == tabId }) {
                    tabs[index].isVisible = isVisible
                }
            }
            
            for (tabId, isEnabled) in state.tabEnabled {
                if let index = tabs.firstIndex(where: { $0.id == tabId }) {
                    tabs[index].isEnabled = isEnabled
                }
            }
        }
    }
    
    /// Clears saved state
    public func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: configuration.persistenceKey)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup any necessary Combine bindings
    }
    
    private func handleTabReselection(_ tab: TabItem) {
        if configuration.doubleTapResetsNavigation {
            popToRoot(for: tab.id)
        }
        
        let event = TabNavigationEvent.tabReselected(tabId: tab.id)
        lastEvent = event
        notifyHandlers(event)
    }
    
    private func notifyHandlers(_ event: TabNavigationEvent) {
        for handler in tabChangeHandlers {
            handler(event)
        }
    }
    
    private func addToHistory(_ tabId: String) {
        historyStack.append(tabId)
        if historyStack.count > maxHistorySize {
            historyStack.removeFirst()
        }
    }
}

// MARK: - Codable State

private struct CodableState: Codable {
    let selectedTabId: String
    let navigationStacks: [String: [String]]
    let tabVisibility: [String: Bool]
    let tabEnabled: [String: Bool]
    
    init(state: TabRouterState) {
        self.selectedTabId = state.selectedTabId
        self.navigationStacks = state.navigationStacks
        self.tabVisibility = state.tabVisibility
        self.tabEnabled = state.tabEnabled
    }
    
    func toState() -> TabRouterState {
        TabRouterState(
            selectedTabId: selectedTabId,
            navigationStacks: navigationStacks,
            tabVisibility: tabVisibility,
            tabEnabled: tabEnabled
        )
    }
}

// MARK: - SwiftUI Environment

private struct TabRouterKey: EnvironmentKey {
    static let defaultValue: TabRouter? = nil
}

public extension EnvironmentValues {
    var tabRouter: TabRouter? {
        get { self[TabRouterKey.self] }
        set { self[TabRouterKey.self] = newValue }
    }
}

public extension View {
    /// Injects a tab router into the environment
    func tabRouter(_ router: TabRouter) -> some View {
        environment(\.tabRouter, router)
    }
}
