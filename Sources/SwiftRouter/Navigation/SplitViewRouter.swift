//
//  SplitViewRouter.swift
//  SwiftRouter
//
//  Created by Muhittin Camdali on 2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Split View Column

/// Represents a column in a split view
public struct SplitViewColumn: Identifiable, Hashable, Sendable {
    
    /// Column type
    public enum ColumnType: String, Hashable, Sendable {
        case sidebar
        case content
        case detail
        case supplementary
    }
    
    /// Column visibility
    public enum Visibility: Hashable, Sendable {
        case automatic
        case visible
        case hidden
        case detailOnly
    }
    
    /// Unique identifier
    public let id: UUID
    
    /// Column type
    public let type: ColumnType
    
    /// Preferred width
    public var preferredWidth: CGFloat?
    
    /// Minimum width
    public var minimumWidth: CGFloat?
    
    /// Maximum width
    public var maximumWidth: CGFloat?
    
    /// Ideal width
    public var idealWidth: CGFloat?
    
    /// Current visibility
    public var visibility: Visibility
    
    /// Navigation stack
    public var navigationStack: [String]
    
    /// Whether column is collapsible
    public var isCollapsible: Bool
    
    /// Creates a split view column
    /// - Parameters:
    ///   - type: Column type
    ///   - preferredWidth: Preferred width
    ///   - minimumWidth: Minimum width
    ///   - maximumWidth: Maximum width
    ///   - visibility: Initial visibility
    ///   - isCollapsible: Whether collapsible
    public init(
        type: ColumnType,
        preferredWidth: CGFloat? = nil,
        minimumWidth: CGFloat? = nil,
        maximumWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        visibility: Visibility = .automatic,
        isCollapsible: Bool = true
    ) {
        self.id = UUID()
        self.type = type
        self.preferredWidth = preferredWidth
        self.minimumWidth = minimumWidth
        self.maximumWidth = maximumWidth
        self.idealWidth = idealWidth
        self.visibility = visibility
        self.navigationStack = []
        self.isCollapsible = isCollapsible
    }
    
    /// Creates sidebar column with defaults
    public static func sidebar(
        width: CGFloat = 250,
        minimumWidth: CGFloat = 180,
        maximumWidth: CGFloat = 320
    ) -> SplitViewColumn {
        SplitViewColumn(
            type: .sidebar,
            preferredWidth: width,
            minimumWidth: minimumWidth,
            maximumWidth: maximumWidth
        )
    }
    
    /// Creates content column with defaults
    public static func content(
        width: CGFloat = 350,
        minimumWidth: CGFloat = 280
    ) -> SplitViewColumn {
        SplitViewColumn(
            type: .content,
            preferredWidth: width,
            minimumWidth: minimumWidth
        )
    }
    
    /// Creates detail column with defaults
    public static func detail() -> SplitViewColumn {
        SplitViewColumn(
            type: .detail,
            minimumWidth: 400
        )
    }
}

// MARK: - Split View Layout

/// Split view layout configurations
public struct SplitViewLayout: Equatable, Sendable {
    
    /// Layout style
    public enum Style: String, Equatable, Sendable {
        case doubleColumn
        case tripleColumn
        case automatic
    }
    
    /// Preferred compact column
    public enum PreferredCompactColumn: String, Equatable, Sendable {
        case sidebar
        case content
        case detail
    }
    
    /// Layout style
    public let style: Style
    
    /// Preferred compact column
    public var preferredCompactColumn: PreferredCompactColumn
    
    /// Whether sidebar is always visible on large screens
    public var prominentDetail: Bool
    
    /// Balance split behavior
    public var balanced: Bool
    
    /// Creates a split view layout
    public init(
        style: Style,
        preferredCompactColumn: PreferredCompactColumn = .sidebar,
        prominentDetail: Bool = false,
        balanced: Bool = true
    ) {
        self.style = style
        self.preferredCompactColumn = preferredCompactColumn
        self.prominentDetail = prominentDetail
        self.balanced = balanced
    }
    
    /// Two-column layout
    public static let doubleColumn = SplitViewLayout(style: .doubleColumn)
    
    /// Three-column layout
    public static let tripleColumn = SplitViewLayout(style: .tripleColumn)
}

// MARK: - Split View State

/// State of the split view router
public struct SplitViewState: Equatable, Sendable {
    
    /// Current layout
    public var layout: SplitViewLayout
    
    /// Column visibility states
    public var columnVisibility: NavigationSplitViewVisibility
    
    /// Selected sidebar item
    public var selectedSidebarItem: String?
    
    /// Selected content item
    public var selectedContentItem: String?
    
    /// Current detail route
    public var detailRoute: String?
    
    /// Size class
    public var horizontalSizeClass: UserInterfaceSizeClass?
    
    /// Creates initial state
    public init(
        layout: SplitViewLayout = .doubleColumn,
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        selectedSidebarItem: String? = nil,
        selectedContentItem: String? = nil,
        detailRoute: String? = nil,
        horizontalSizeClass: UserInterfaceSizeClass? = nil
    ) {
        self.layout = layout
        self.columnVisibility = columnVisibility
        self.selectedSidebarItem = selectedSidebarItem
        self.selectedContentItem = selectedContentItem
        self.detailRoute = detailRoute
        self.horizontalSizeClass = horizontalSizeClass
    }
}

// MARK: - Split View Event

/// Events during split view navigation
public enum SplitViewEvent: Equatable, Sendable {
    case sidebarItemSelected(item: String)
    case contentItemSelected(item: String)
    case detailRouteChanged(route: String?)
    case columnVisibilityChanged(visibility: NavigationSplitViewVisibility)
    case layoutChanged(layout: SplitViewLayout)
    case sizeClassChanged(sizeClass: UserInterfaceSizeClass)
    case navigationStackChanged(column: SplitViewColumn.ColumnType, stack: [String])
}

// MARK: - Split View Error

/// Errors during split view routing
public enum SplitViewError: Error, LocalizedError, Sendable {
    case columnNotFound(SplitViewColumn.ColumnType)
    case invalidRoute(String)
    case navigationFailed(String)
    case invalidConfiguration
    case stateRestoreFailed
    
    public var errorDescription: String? {
        switch self {
        case .columnNotFound(let type):
            return "Column not found: \(type.rawValue)"
        case .invalidRoute(let route):
            return "Invalid route: \(route)"
        case .navigationFailed(let reason):
            return "Navigation failed: \(reason)"
        case .invalidConfiguration:
            return "Invalid split view configuration"
        case .stateRestoreFailed:
            return "Failed to restore split view state"
        }
    }
}

// MARK: - Split View Router Protocol

/// Protocol for split view router implementations
public protocol SplitViewRouterProtocol: AnyObject {
    
    /// Current state
    var state: SplitViewState { get }
    
    /// Selects a sidebar item
    func selectSidebarItem(_ item: String)
    
    /// Selects a content item
    func selectContentItem(_ item: String)
    
    /// Navigates to detail
    func navigateToDetail(_ route: String)
    
    /// Sets column visibility
    func setColumnVisibility(_ visibility: NavigationSplitViewVisibility)
}

// MARK: - Split View Router

/// Main split view router implementation
@MainActor
public final class SplitViewRouter: ObservableObject, SplitViewRouterProtocol {
    
    // MARK: - Published Properties
    
    /// Current state
    @Published public private(set) var state: SplitViewState
    
    /// Column visibility binding
    @Published public var columnVisibility: NavigationSplitViewVisibility = .automatic
    
    /// Selected sidebar item
    @Published public var selectedSidebarItem: String?
    
    /// Selected content item
    @Published public var selectedContentItem: String?
    
    /// Detail navigation path
    @Published public var detailPath: NavigationPath = NavigationPath()
    
    /// Last event
    @Published public private(set) var lastEvent: SplitViewEvent?
    
    /// Last error
    @Published public private(set) var lastError: SplitViewError?
    
    // MARK: - Private Properties
    
    private var columns: [SplitViewColumn.ColumnType: SplitViewColumn] = [:]
    private var sidebarItems: [String] = []
    private var contentItems: [String: [String]] = [:]
    private var eventHandlers: [(SplitViewEvent) -> Void] = []
    private var cancellables = Set<AnyCancellable>()
    private let configuration: Configuration
    
    // MARK: - Configuration
    
    /// Router configuration
    public struct Configuration {
        
        /// Layout
        public var layout: SplitViewLayout
        
        /// Whether to persist state
        public var persistState: Bool
        
        /// Persistence key
        public var persistenceKey: String
        
        /// Whether sidebar auto-selects first item
        public var autoSelectFirstSidebarItem: Bool
        
        /// Whether content auto-selects first item
        public var autoSelectFirstContentItem: Bool
        
        /// Adaptive behavior
        public var adaptiveCompactBehavior: Bool
        
        /// Creates configuration
        public init(
            layout: SplitViewLayout = .doubleColumn,
            persistState: Bool = true,
            persistenceKey: String = "SplitViewRouterState",
            autoSelectFirstSidebarItem: Bool = true,
            autoSelectFirstContentItem: Bool = true,
            adaptiveCompactBehavior: Bool = true
        ) {
            self.layout = layout
            self.persistState = persistState
            self.persistenceKey = persistenceKey
            self.autoSelectFirstSidebarItem = autoSelectFirstSidebarItem
            self.autoSelectFirstContentItem = autoSelectFirstContentItem
            self.adaptiveCompactBehavior = adaptiveCompactBehavior
        }
        
        public static let `default` = Configuration()
    }
    
    // MARK: - Initialization
    
    /// Creates a split view router
    /// - Parameter configuration: Router configuration
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.state = SplitViewState(layout: configuration.layout)
        
        setupColumns()
        setupBindings()
        
        if configuration.persistState {
            restoreState()
        }
    }
    
    // MARK: - Column Management
    
    /// Configures a column
    /// - Parameter column: Column to configure
    public func configureColumn(_ column: SplitViewColumn) {
        columns[column.type] = column
    }
    
    /// Gets a column
    /// - Parameter type: Column type
    /// - Returns: Column if found
    public func getColumn(_ type: SplitViewColumn.ColumnType) -> SplitViewColumn? {
        columns[type]
    }
    
    /// Sets column width
    /// - Parameters:
    ///   - width: New width
    ///   - type: Column type
    public func setColumnWidth(_ width: CGFloat, for type: SplitViewColumn.ColumnType) {
        guard var column = columns[type] else { return }
        column.preferredWidth = width
        columns[type] = column
    }
    
    /// Sets column visibility
    /// - Parameters:
    ///   - visibility: New visibility
    ///   - type: Column type
    public func setColumnVisibility(_ visibility: SplitViewColumn.Visibility, for type: SplitViewColumn.ColumnType) {
        guard var column = columns[type] else { return }
        column.visibility = visibility
        columns[type] = column
    }
    
    // MARK: - Sidebar Management
    
    /// Registers sidebar items
    /// - Parameter items: Items to register
    public func registerSidebarItems(_ items: [String]) {
        self.sidebarItems = items
        
        if configuration.autoSelectFirstSidebarItem && selectedSidebarItem == nil {
            selectSidebarItem(items.first ?? "")
        }
    }
    
    /// Registers content items for a sidebar item
    /// - Parameters:
    ///   - items: Content items
    ///   - sidebarItem: Parent sidebar item
    public func registerContentItems(_ items: [String], for sidebarItem: String) {
        contentItems[sidebarItem] = items
    }
    
    /// Gets content items for sidebar item
    /// - Parameter sidebarItem: Sidebar item
    /// - Returns: Content items
    public func getContentItems(for sidebarItem: String) -> [String] {
        contentItems[sidebarItem] ?? []
    }
    
    // MARK: - Navigation
    
    /// Selects a sidebar item
    /// - Parameter item: Item to select
    public func selectSidebarItem(_ item: String) {
        let previousItem = selectedSidebarItem
        selectedSidebarItem = item
        state.selectedSidebarItem = item
        
        // Clear content selection when sidebar changes
        if previousItem != item {
            selectedContentItem = nil
            state.selectedContentItem = nil
            
            // Auto-select first content item if enabled
            if configuration.autoSelectFirstContentItem {
                if let firstContent = contentItems[item]?.first {
                    selectContentItem(firstContent)
                }
            }
        }
        
        let event = SplitViewEvent.sidebarItemSelected(item: item)
        lastEvent = event
        notifyHandlers(event)
        
        saveState()
    }
    
    /// Selects a content item
    /// - Parameter item: Item to select
    public func selectContentItem(_ item: String) {
        selectedContentItem = item
        state.selectedContentItem = item
        
        let event = SplitViewEvent.contentItemSelected(item: item)
        lastEvent = event
        notifyHandlers(event)
        
        saveState()
    }
    
    /// Navigates to a detail route
    /// - Parameter route: Route to navigate to
    public func navigateToDetail(_ route: String) {
        state.detailRoute = route
        
        let event = SplitViewEvent.detailRouteChanged(route: route)
        lastEvent = event
        notifyHandlers(event)
        
        saveState()
    }
    
    /// Clears detail route
    public func clearDetail() {
        state.detailRoute = nil
        detailPath = NavigationPath()
        
        let event = SplitViewEvent.detailRouteChanged(route: nil)
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Pushes to detail navigation stack
    /// - Parameter route: Route to push
    public func pushDetail(_ route: some Hashable) {
        detailPath.append(route)
        
        let event = SplitViewEvent.navigationStackChanged(column: .detail, stack: [])
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Pops from detail navigation stack
    public func popDetail() {
        guard !detailPath.isEmpty else { return }
        detailPath.removeLast()
        
        let event = SplitViewEvent.navigationStackChanged(column: .detail, stack: [])
        lastEvent = event
        notifyHandlers(event)
    }
    
    /// Pops to root in detail
    public func popDetailToRoot() {
        detailPath = NavigationPath()
        
        let event = SplitViewEvent.navigationStackChanged(column: .detail, stack: [])
        lastEvent = event
        notifyHandlers(event)
    }
    
    // MARK: - Column Visibility
    
    /// Sets the column visibility
    /// - Parameter visibility: New visibility
    public func setColumnVisibility(_ visibility: NavigationSplitViewVisibility) {
        columnVisibility = visibility
        state.columnVisibility = visibility
        
        let event = SplitViewEvent.columnVisibilityChanged(visibility: visibility)
        lastEvent = event
        notifyHandlers(event)
        
        saveState()
    }
    
    /// Shows all columns
    public func showAllColumns() {
        setColumnVisibility(.all)
    }
    
    /// Shows detail only
    public func showDetailOnly() {
        setColumnVisibility(.detailOnly)
    }
    
    /// Shows double column (sidebar + detail)
    public func showDoubleColumn() {
        setColumnVisibility(.doubleColumn)
    }
    
    /// Toggles sidebar visibility
    public func toggleSidebar() {
        switch columnVisibility {
        case .all:
            setColumnVisibility(.detailOnly)
        case .detailOnly:
            setColumnVisibility(.all)
        default:
            setColumnVisibility(.automatic)
        }
    }
    
    // MARK: - Layout
    
    /// Updates layout
    /// - Parameter layout: New layout
    public func updateLayout(_ layout: SplitViewLayout) {
        state.layout = layout
        
        let event = SplitViewEvent.layoutChanged(layout: layout)
        lastEvent = event
        notifyHandlers(event)
        
        saveState()
    }
    
    /// Updates size class
    /// - Parameter sizeClass: New size class
    public func updateSizeClass(_ sizeClass: UserInterfaceSizeClass) {
        state.horizontalSizeClass = sizeClass
        
        let event = SplitViewEvent.sizeClassChanged(sizeClass: sizeClass)
        lastEvent = event
        notifyHandlers(event)
        
        // Adapt to compact if needed
        if configuration.adaptiveCompactBehavior && sizeClass == .compact {
            adaptToCompact()
        }
    }
    
    // MARK: - Event Handling
    
    /// Adds an event handler
    /// - Parameter handler: Handler closure
    public func onEvent(_ handler: @escaping (SplitViewEvent) -> Void) {
        eventHandlers.append(handler)
    }
    
    // MARK: - State Management
    
    /// Saves current state
    public func saveState() {
        guard configuration.persistState else { return }
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(CodableSplitState(
            selectedSidebarItem: state.selectedSidebarItem,
            selectedContentItem: state.selectedContentItem,
            detailRoute: state.detailRoute
        )) {
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
        if let saved = try? decoder.decode(CodableSplitState.self, from: data) {
            if let sidebar = saved.selectedSidebarItem {
                selectSidebarItem(sidebar)
            }
            if let content = saved.selectedContentItem {
                selectContentItem(content)
            }
            if let detail = saved.detailRoute {
                navigateToDetail(detail)
            }
        }
    }
    
    /// Clears saved state
    public func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: configuration.persistenceKey)
    }
    
    /// Resets to initial state
    public func reset() {
        selectedSidebarItem = nil
        selectedContentItem = nil
        state = SplitViewState(layout: configuration.layout)
        detailPath = NavigationPath()
        columnVisibility = .automatic
        clearSavedState()
    }
    
    // MARK: - Private Methods
    
    private func setupColumns() {
        let layout = configuration.layout
        
        switch layout.style {
        case .doubleColumn:
            columns[.sidebar] = .sidebar()
            columns[.detail] = .detail()
        case .tripleColumn:
            columns[.sidebar] = .sidebar()
            columns[.content] = .content()
            columns[.detail] = .detail()
        case .automatic:
            columns[.sidebar] = .sidebar()
            columns[.detail] = .detail()
        }
    }
    
    private func setupBindings() {
        $selectedSidebarItem
            .sink { [weak self] item in
                self?.state.selectedSidebarItem = item
            }
            .store(in: &cancellables)
        
        $selectedContentItem
            .sink { [weak self] item in
                self?.state.selectedContentItem = item
            }
            .store(in: &cancellables)
        
        $columnVisibility
            .sink { [weak self] visibility in
                self?.state.columnVisibility = visibility
            }
            .store(in: &cancellables)
    }
    
    private func adaptToCompact() {
        // In compact mode, show based on selection state
        if state.detailRoute != nil || selectedContentItem != nil {
            setColumnVisibility(.detailOnly)
        } else if selectedSidebarItem != nil {
            if configuration.layout.style == .tripleColumn {
                setColumnVisibility(.doubleColumn)
            }
        }
    }
    
    private func notifyHandlers(_ event: SplitViewEvent) {
        for handler in eventHandlers {
            handler(event)
        }
    }
}

// MARK: - Codable State

private struct CodableSplitState: Codable {
    let selectedSidebarItem: String?
    let selectedContentItem: String?
    let detailRoute: String?
}

// MARK: - SwiftUI Environment

private struct SplitViewRouterKey: EnvironmentKey {
    static let defaultValue: SplitViewRouter? = nil
}

public extension EnvironmentValues {
    var splitViewRouter: SplitViewRouter? {
        get { self[SplitViewRouterKey.self] }
        set { self[SplitViewRouterKey.self] = newValue }
    }
}

public extension View {
    /// Injects a split view router into the environment
    func splitViewRouter(_ router: SplitViewRouter) -> some View {
        environment(\.splitViewRouter, router)
    }
    
    /// Tracks size class changes
    func trackSizeClass(router: SplitViewRouter) -> some View {
        modifier(SizeClassTracker(router: router))
    }
}

// MARK: - Size Class Tracker

private struct SizeClassTracker: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let router: SplitViewRouter
    
    func body(content: Content) -> some View {
        content
            .onChange(of: horizontalSizeClass) { _, newValue in
                if let sizeClass = newValue {
                    router.updateSizeClass(sizeClass)
                }
            }
    }
}
