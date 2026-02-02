// NavigationStack.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation
import Combine

// MARK: - Navigation Entry

/// A single entry in the navigation stack representing a navigated route.
///
/// Each ``NavigationEntry`` captures the route, the action that produced it,
/// and a unique identifier for tracking purposes.
public struct NavigationEntry: Identifiable, Sendable {

    /// Unique identifier for this stack entry.
    public let id: UUID

    /// The route that was navigated to.
    public let route: any Route

    /// The navigation action that produced this entry.
    public let action: NavigationAction

    /// The timestamp when this entry was created.
    public let timestamp: Date

    /// Whether this entry represents a modal presentation.
    public let isModal: Bool

    /// The transition style used for this entry.
    public let transitionStyle: TransitionStyle

    /// Optional tag for programmatic lookup.
    public let tag: String?

    /// Creates a new navigation entry.
    ///
    /// - Parameters:
    ///   - route: The route for this entry.
    ///   - action: The navigation action.
    ///   - isModal: Whether this is a modal presentation.
    ///   - transitionStyle: The transition style.
    ///   - tag: Optional tag for lookup.
    public init(
        route: any Route,
        action: NavigationAction,
        isModal: Bool = false,
        transitionStyle: TransitionStyle = .push,
        tag: String? = nil
    ) {
        self.id = UUID()
        self.route = route
        self.action = action
        self.timestamp = Date()
        self.isModal = isModal
        self.transitionStyle = transitionStyle
        self.tag = tag
    }
}

// MARK: - Navigation Stack

/// A managed navigation stack that tracks the history of navigated routes.
///
/// ``NavigationStack`` provides push, pop, present, and dismiss operations
/// with support for maximum depth enforcement and history tracking.
///
/// ## Overview
///
/// The navigation stack maintains two separate collections:
/// - A primary stack for pushed routes
/// - A modal stack for presented routes
///
/// This separation allows modal presentations to overlay the push stack
/// without disturbing the underlying navigation hierarchy.
public final class NavigationStack: ObservableObject {

    // MARK: - Properties

    /// The primary navigation entries (push stack).
    @Published public private(set) var entries: [NavigationEntry] = []

    /// The modal presentation entries.
    @Published public private(set) var modalEntries: [NavigationEntry] = []

    /// The maximum allowed stack depth.
    public let maxDepth: Int

    /// The current depth of the combined navigation stack.
    public var depth: Int { entries.count + modalEntries.count }

    /// Whether the navigation stack is empty.
    public var isEmpty: Bool { entries.isEmpty && modalEntries.isEmpty }

    /// The topmost entry on the stack (modal takes priority).
    public var topEntry: NavigationEntry? {
        modalEntries.last ?? entries.last
    }

    /// The topmost route on the stack.
    public var topRoute: (any Route)? {
        topEntry?.route
    }

    /// The root entry of the push stack.
    public var rootEntry: NavigationEntry? {
        entries.first
    }

    /// A complete history of all navigation operations performed.
    @Published public private(set) var history: [NavigationHistoryItem] = []

    /// Publisher that emits stack change events.
    public let stackChanged = PassthroughSubject<StackChangeEvent, Never>()

    // MARK: - Initialization

    /// Creates a new navigation stack.
    ///
    /// - Parameter maxDepth: The maximum stack depth. Defaults to `50`.
    public init(maxDepth: Int = 50) {
        self.maxDepth = maxDepth
    }

    // MARK: - Push Operations

    /// Pushes a route onto the navigation stack.
    ///
    /// - Parameters:
    ///   - route: The route to push.
    ///   - style: The transition style. Defaults to `.push`.
    ///   - tag: Optional tag for the entry.
    /// - Throws: ``RouterError/stackOverflow(maxDepth:)`` if the stack is full.
    public func push(
        _ route: any Route,
        style: TransitionStyle = .push,
        tag: String? = nil
    ) throws {
        guard depth < maxDepth else {
            throw RouterError.stackOverflow(maxDepth: maxDepth)
        }

        let entry = NavigationEntry(
            route: route,
            action: .push,
            isModal: false,
            transitionStyle: style,
            tag: tag
        )
        entries.append(entry)
        recordHistory(.push, entry: entry)
        stackChanged.send(.pushed(entry))
    }

    /// Pushes multiple routes onto the stack in order.
    ///
    /// - Parameter routes: The routes to push.
    /// - Throws: ``RouterError/stackOverflow(maxDepth:)`` if the stack would exceed max depth.
    public func pushAll(_ routes: [any Route]) throws {
        guard depth + routes.count <= maxDepth else {
            throw RouterError.stackOverflow(maxDepth: maxDepth)
        }

        for route in routes {
            try push(route)
        }
    }

    // MARK: - Pop Operations

    /// Pops the topmost entry from the push stack.
    ///
    /// - Returns: The popped entry, or `nil` if the stack is empty.
    @discardableResult
    public func pop() -> NavigationEntry? {
        guard let entry = entries.popLast() else { return nil }
        recordHistory(.pop, entry: entry)
        stackChanged.send(.popped(entry))
        return entry
    }

    /// Pops entries until the specified tag is found.
    ///
    /// - Parameter tag: The tag to pop to.
    /// - Returns: The entries that were popped.
    @discardableResult
    public func pop(to tag: String) -> [NavigationEntry] {
        var popped: [NavigationEntry] = []
        while let last = entries.last, last.tag != tag {
            if let entry = entries.popLast() {
                popped.append(entry)
                recordHistory(.pop, entry: entry)
            }
        }
        if !popped.isEmpty {
            stackChanged.send(.poppedMultiple(popped))
        }
        return popped
    }

    /// Pops all entries except the root.
    ///
    /// - Returns: The entries that were popped.
    @discardableResult
    public func popToRoot() -> [NavigationEntry] {
        guard entries.count > 1 else { return [] }
        let popped = Array(entries.dropFirst())
        entries = Array(entries.prefix(1))
        for entry in popped {
            recordHistory(.pop, entry: entry)
        }
        stackChanged.send(.poppedToRoot(popped))
        return popped
    }

    /// Pops a specific number of entries from the stack.
    ///
    /// - Parameter count: The number of entries to pop.
    /// - Returns: The popped entries.
    @discardableResult
    public func pop(count: Int) -> [NavigationEntry] {
        let actualCount = min(count, entries.count)
        var popped: [NavigationEntry] = []
        for _ in 0..<actualCount {
            if let entry = entries.popLast() {
                popped.append(entry)
                recordHistory(.pop, entry: entry)
            }
        }
        if !popped.isEmpty {
            stackChanged.send(.poppedMultiple(popped))
        }
        return popped
    }

    // MARK: - Present / Dismiss

    /// Presents a route modally.
    ///
    /// - Parameters:
    ///   - route: The route to present.
    ///   - style: The presentation style. Defaults to `.sheet`.
    /// - Throws: ``RouterError/stackOverflow(maxDepth:)`` if the stack is full.
    public func present(
        _ route: any Route,
        style: TransitionStyle = .sheet
    ) throws {
        guard depth < maxDepth else {
            throw RouterError.stackOverflow(maxDepth: maxDepth)
        }

        let entry = NavigationEntry(
            route: route,
            action: .present(style: style),
            isModal: true,
            transitionStyle: style
        )
        modalEntries.append(entry)
        recordHistory(.present, entry: entry)
        stackChanged.send(.presented(entry))
    }

    /// Dismisses the topmost modal entry.
    ///
    /// - Returns: The dismissed entry, or `nil` if no modals are presented.
    @discardableResult
    public func dismiss() -> NavigationEntry? {
        guard let entry = modalEntries.popLast() else { return nil }
        recordHistory(.dismiss, entry: entry)
        stackChanged.send(.dismissed(entry))
        return entry
    }

    /// Dismisses all modal entries.
    ///
    /// - Returns: The dismissed entries.
    @discardableResult
    public func dismissAll() -> [NavigationEntry] {
        let dismissed = modalEntries
        modalEntries.removeAll()
        for entry in dismissed {
            recordHistory(.dismiss, entry: entry)
        }
        if !dismissed.isEmpty {
            stackChanged.send(.dismissedAll(dismissed))
        }
        return dismissed
    }

    // MARK: - Replace

    /// Replaces the topmost push entry with a new route.
    ///
    /// - Parameter route: The replacement route.
    /// - Throws: ``RouterError/stackOverflow(maxDepth:)`` if the stack is full and empty.
    public func replace(with route: any Route) throws {
        if !entries.isEmpty {
            let removed = entries.removeLast()
            recordHistory(.pop, entry: removed)
        }
        try push(route)
    }

    /// Replaces the entire push stack with a new set of routes.
    ///
    /// - Parameter routes: The new routes.
    public func replaceAll(with routes: [any Route]) throws {
        let oldEntries = entries
        entries.removeAll()
        for entry in oldEntries {
            recordHistory(.pop, entry: entry)
        }
        try pushAll(routes)
    }

    // MARK: - Query

    /// Finds the first entry matching the given predicate.
    ///
    /// - Parameter predicate: A closure that evaluates each entry.
    /// - Returns: The first matching entry, or `nil`.
    public func find(where predicate: (NavigationEntry) -> Bool) -> NavigationEntry? {
        entries.first(where: predicate) ?? modalEntries.first(where: predicate)
    }

    /// Checks whether a route with the given pattern exists in the stack.
    ///
    /// - Parameter pattern: The route pattern to search for.
    /// - Returns: `true` if found.
    public func contains(pattern: String) -> Bool {
        entries.contains { $0.route.pattern == pattern } ||
        modalEntries.contains { $0.route.pattern == pattern }
    }

    /// Clears the entire navigation stack including modals and history.
    public func clear() {
        entries.removeAll()
        modalEntries.removeAll()
        history.removeAll()
        stackChanged.send(.cleared)
    }

    // MARK: - Private

    private func recordHistory(_ operation: NavigationOperation, entry: NavigationEntry) {
        let item = NavigationHistoryItem(
            operation: operation,
            entry: entry,
            timestamp: Date(),
            stackDepthAfter: depth
        )
        history.append(item)
    }
}

// MARK: - Stack Change Event

/// Events emitted by the navigation stack when its state changes.
public enum StackChangeEvent: Sendable {
    case pushed(NavigationEntry)
    case popped(NavigationEntry)
    case poppedMultiple([NavigationEntry])
    case poppedToRoot([NavigationEntry])
    case presented(NavigationEntry)
    case dismissed(NavigationEntry)
    case dismissedAll([NavigationEntry])
    case cleared
}

// MARK: - Navigation Operation

/// The type of navigation operation performed.
public enum NavigationOperation: String, Sendable {
    case push
    case pop
    case present
    case dismiss
    case replace
}

// MARK: - Navigation History Item

/// A record of a single navigation operation in the history.
public struct NavigationHistoryItem: Sendable {

    /// The operation that was performed.
    public let operation: NavigationOperation

    /// The navigation entry involved.
    public let entry: NavigationEntry

    /// When the operation occurred.
    public let timestamp: Date

    /// The stack depth after the operation.
    public let stackDepthAfter: Int
}
