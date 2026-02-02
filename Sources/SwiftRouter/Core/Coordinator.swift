// Coordinator.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation
import Combine

// MARK: - Coordinator Protocol

/// A protocol for implementing the Coordinator pattern with SwiftRouter.
///
/// Coordinators manage navigation flow for a specific feature or section
/// of the app. They own a ``Router`` (or share one) and orchestrate
/// navigation between related screens.
///
/// ## Usage
///
/// ```swift
/// final class ProfileCoordinator: Coordinator {
///     let id = UUID()
///     let router: Router
///     var childCoordinators: [any Coordinator] = []
///     weak var parentCoordinator: (any Coordinator)?
///
///     init(router: Router) {
///         self.router = router
///     }
///
///     func start() async {
///         try? await router.navigate(to: ProfileRoute(userId: "me"))
///     }
/// }
/// ```
@MainActor
public protocol Coordinator: AnyObject {

    /// Unique identifier for this coordinator.
    var id: UUID { get }

    /// The router managed by this coordinator.
    var router: Router { get }

    /// Child coordinators managed by this coordinator.
    var childCoordinators: [any Coordinator] { get set }

    /// The parent coordinator, if any.
    var parentCoordinator: (any Coordinator)? { get set }

    /// Starts the coordinator's flow.
    ///
    /// Called when the coordinator should begin its navigation sequence.
    /// Typically navigates to the initial screen of the feature.
    func start() async

    /// Finishes the coordinator's flow and cleans up.
    ///
    /// Called when the coordinator's work is done. Should notify the parent
    /// coordinator and remove itself from the parent's child list.
    func finish() async

    /// Handles a deep link URL within this coordinator's scope.
    ///
    /// - Parameter url: The deep link URL.
    /// - Returns: `true` if this coordinator handled the link.
    func handleDeepLink(_ url: URL) async -> Bool
}

/// Default implementations for ``Coordinator`` methods.
public extension Coordinator {

    /// Default finish implementation that removes self from parent.
    func finish() async {
        parentCoordinator?.removeChild(self)
        childCoordinators.removeAll()
    }

    /// Default deep link handling returns `false`.
    func handleDeepLink(_ url: URL) async -> Bool {
        // Try child coordinators first
        for child in childCoordinators {
            if await child.handleDeepLink(url) {
                return true
            }
        }
        return false
    }

    /// Adds a child coordinator.
    ///
    /// - Parameter coordinator: The child coordinator to add.
    func addChild(_ coordinator: any Coordinator) {
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    /// Removes a child coordinator.
    ///
    /// - Parameter coordinator: The child coordinator to remove.
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0.id == coordinator.id }
    }

    /// Finds a child coordinator of the specified type.
    ///
    /// - Parameter type: The coordinator type to search for.
    /// - Returns: The first matching child coordinator, or `nil`.
    func findChild<C: Coordinator>(ofType type: C.Type) -> C? {
        childCoordinators.first { $0 is C } as? C
    }

    /// Removes all child coordinators.
    func removeAllChildren() {
        childCoordinators.forEach { $0.parentCoordinator = nil }
        childCoordinators.removeAll()
    }
}

// MARK: - App Coordinator

/// A base class for the application's root coordinator.
///
/// ``AppCoordinator`` serves as the starting point of the coordinator tree.
/// It manages top-level navigation and dispatches deep links to the appropriate
/// child coordinator.
///
/// ## Example
///
/// ```swift
/// let appCoordinator = AppCoordinator(router: mainRouter)
/// await appCoordinator.start()
/// ```
@MainActor
open class AppCoordinator: Coordinator {

    // MARK: - Properties

    /// Unique identifier for this coordinator.
    public let id = UUID()

    /// The router instance.
    public let router: Router

    /// Child coordinators.
    public var childCoordinators: [any Coordinator] = []

    /// Always `nil` for the app coordinator.
    public weak var parentCoordinator: (any Coordinator)?

    /// Whether the coordinator has been started.
    public private(set) var isStarted: Bool = false

    /// Publisher for coordinator lifecycle events.
    public let lifecycleEvent = PassthroughSubject<CoordinatorLifecycleEvent, Never>()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new app coordinator with the specified router.
    ///
    /// - Parameter router: The root router instance.
    public init(router: Router) {
        self.router = router
    }

    // MARK: - Coordinator

    /// Starts the app coordinator.
    ///
    /// Override this method to set up your initial navigation structure,
    /// such as a tab bar or initial screen.
    open func start() async {
        isStarted = true
        lifecycleEvent.send(.started)
    }

    /// Finishes the app coordinator and all children.
    open func finish() async {
        for child in childCoordinators {
            await child.finish()
        }
        childCoordinators.removeAll()
        isStarted = false
        lifecycleEvent.send(.finished)
    }

    /// Handles a deep link by dispatching to child coordinators.
    ///
    /// - Parameter url: The deep link URL.
    /// - Returns: `true` if any coordinator handled the link.
    open func handleDeepLink(_ url: URL) async -> Bool {
        for child in childCoordinators {
            if await child.handleDeepLink(url) {
                return true
            }
        }

        // Fall back to router's deep link handler
        do {
            try await router.handleDeepLink(url)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Flow Management

    /// Starts a child coordinator flow.
    ///
    /// - Parameter coordinator: The child coordinator to start.
    public func startFlow(_ coordinator: any Coordinator) async {
        addChild(coordinator)
        await coordinator.start()
        lifecycleEvent.send(.childStarted(coordinator.id))
    }

    /// Ends a child coordinator flow.
    ///
    /// - Parameter coordinator: The child coordinator to finish.
    public func endFlow(_ coordinator: any Coordinator) async {
        await coordinator.finish()
        removeChild(coordinator)
        lifecycleEvent.send(.childFinished(coordinator.id))
    }

    /// Switches from one child flow to another.
    ///
    /// - Parameters:
    ///   - from: The coordinator to finish.
    ///   - to: The coordinator to start.
    public func switchFlow(from: any Coordinator, to: any Coordinator) async {
        await endFlow(from)
        await startFlow(to)
    }
}

// MARK: - Coordinator Lifecycle Event

/// Events emitted during coordinator lifecycle changes.
public enum CoordinatorLifecycleEvent: Sendable {

    /// The coordinator has started.
    case started

    /// The coordinator has finished.
    case finished

    /// A child coordinator was started.
    case childStarted(UUID)

    /// A child coordinator was finished.
    case childFinished(UUID)
}

// MARK: - Tab Coordinator

/// A coordinator that manages tab-based navigation.
///
/// ``TabCoordinator`` holds one child coordinator per tab and provides
/// convenience methods for switching between them.
@MainActor
open class TabCoordinator: AppCoordinator {

    /// The currently selected tab index.
    @Published public var selectedTabIndex: Int = 0

    /// The coordinators for each tab.
    public private(set) var tabCoordinators: [any Coordinator] = []

    /// Sets up the tab coordinators.
    ///
    /// - Parameter coordinators: One coordinator per tab.
    public func setTabs(_ coordinators: [any Coordinator]) {
        tabCoordinators = coordinators
        for coordinator in coordinators {
            addChild(coordinator)
        }
    }

    /// Switches to the tab at the specified index.
    ///
    /// - Parameter index: The tab index.
    public func selectTab(_ index: Int) async {
        guard index >= 0, index < tabCoordinators.count else { return }
        selectedTabIndex = index
        await tabCoordinators[index].start()
    }

    /// Returns the coordinator for the specified tab index.
    ///
    /// - Parameter index: The tab index.
    /// - Returns: The tab's coordinator, or `nil` if the index is out of range.
    public func coordinator(for index: Int) -> (any Coordinator)? {
        guard index >= 0, index < tabCoordinators.count else { return nil }
        return tabCoordinators[index]
    }
}
