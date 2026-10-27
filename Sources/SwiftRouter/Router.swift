import Observation

/// The result of a navigation request.
public enum NavigationOutcome: Hashable, Sendable {
    /// The navigation state now shows what was asked for.
    case applied
    /// A guard showed other entries; the request is kept in ``Router/pending``.
    case redirected
    /// A guard refused the request; nothing changed.
    case cancelled
    /// The request was not applied because it breaks a limit.
    case rejected(NavigationError)
}

/// Why the router did not apply a request.
public enum NavigationError: Error, Hashable, Sendable {
    /// The request would show more entries than ``Router/maxDepth``.
    case depthLimitExceeded(limit: Int)
}

/// Holds the navigation state of one ``RouterView``: a stack of routes, the sheets and
/// full-screen covers on top of it, and the guards that check every new route.
///
/// Create one router per window or tab and keep it in `@State`:
///
/// ```swift
/// @State private var router = Router<AppRoute>()
///
/// var body: some View {
///     RouterView(router: router) { HomeScreen() }
/// }
/// ```
///
/// Every change goes through the guards (see ``RouteGuard``), so a screen that needs a signed-in
/// user cannot be reached by a push, a deep link, a restored snapshot or a `NavigationLink`.
@MainActor
@Observable
public final class Router<R: Route> {
    /// The entries shown, from the bottom of the root stack to the top-most screen.
    public private(set) var entries: [RouteEntry<R>] = []

    /// A request a guard redirected, kept so that ``resumePending()`` can show it later.
    public private(set) var pending: [RouteEntry<R>]?

    /// The largest number of entries the router shows. Longer requests are rejected.
    public let maxDepth: Int

    /// Changes each time a request coming from SwiftUI is refused, so that the views read the
    /// unchanged state again instead of keeping the screen SwiftUI already pushed.
    private(set) var refusals = 0

    @ObservationIgnored private var guards: [RouteGuard<R>] = []

    /// The default for ``maxDepth``.
    public static var defaultMaxDepth: Int { 64 }

    /// Creates a router.
    ///
    /// - Parameters:
    ///   - entries: The entries to show first. They are not checked by guards, because none is
    ///     added yet.
    ///   - maxDepth: The largest number of entries to show; at least 1.
    public init(entries: [RouteEntry<R>] = [], maxDepth: Int = Router.defaultMaxDepth) {
        precondition(maxDepth >= 1, "maxDepth must be at least 1")
        precondition(entries.count <= maxDepth, "entries must not be longer than maxDepth")
        self.maxDepth = maxDepth
        self.entries = entries
    }

    // MARK: Reading the state

    /// The routes shown, in order. Setting it replaces the state with pushed routes.
    ///
    /// The setter goes through the guards like ``setEntries(_:)``; use that method when you need
    /// the outcome.
    public var path: [R] {
        get { entries.map(\.route) }
        set { setEntries(newValue.map(RouteEntry.push)) }
    }

    /// The top-most route, or `nil` at the root.
    public var top: R? { entries.last?.route }

    /// Whether ``pop(_:)`` would remove a screen.
    public var canPop: Bool { entries.last?.style == .push }

    /// Whether a sheet or full-screen cover is shown.
    public var isPresenting: Bool { entries.contains { $0.style.isModal } }

    // MARK: Guards

    /// Adds a guard that checks every route added from now on.
    public func addGuard(_ routeGuard: RouteGuard<R>) {
        guards.append(routeGuard)
    }

    /// Removes every guard with this name.
    public func removeGuards(named name: String) {
        guards.removeAll { $0.name == name }
    }

    /// Runs the guards over the entries already shown and removes the first entry a guard does
    /// not allow, with everything above it. Call it after the user signs out.
    ///
    /// A redirecting guard shows its fallback in place of the removed entries; the removed
    /// entries are not kept as ``pending``.
    @discardableResult
    public func revalidate() -> NavigationOutcome {
        let shown = entries
        guard let objection = firstObjection(in: shown, after: 0, current: []) else { return .applied }
        let kept = Array(shown[..<objection.index])
        switch objection.decision {
        case .redirect(let fallback):
            entries = Array((kept + fallback).prefix(maxDepth))
            return .redirected
        case .allow, .cancel:
            entries = kept
            return .cancelled
        }
    }

    // MARK: Navigating

    /// Pushes `route` onto the top-most navigation stack.
    @discardableResult
    public func push(_ route: R) -> NavigationOutcome {
        transition(to: entries + [.push(route)])
    }

    /// Pushes `route`; the same as ``push(_:)``.
    @discardableResult
    public func navigate(to route: R) -> NavigationOutcome {
        push(route)
    }

    /// Pushes several routes in one update.
    @discardableResult
    public func push(contentsOf routes: [R]) -> NavigationOutcome {
        transition(to: entries + routes.map(RouteEntry.push))
    }

    /// Shows `route` in the given style on top of the current screen.
    @discardableResult
    public func present(_ route: R, style: PresentationStyle = .sheet) -> NavigationOutcome {
        transition(to: entries + [RouteEntry(route, style: style)])
    }

    /// Replaces the whole navigation state; only the entries that differ from the current
    /// state are checked by the guards.
    @discardableResult
    public func setEntries(_ newEntries: [RouteEntry<R>]) -> NavigationOutcome {
        transition(to: newEntries)
    }

    /// Shows the request a guard redirected, checking it again. Returns `nil` when there is none.
    @discardableResult
    public func resumePending() -> NavigationOutcome? {
        guard let request = pending else { return nil }
        pending = nil
        return transition(to: request)
    }

    /// Forgets the redirected request.
    public func discardPending() {
        pending = nil
    }

    // MARK: Going back

    /// Removes up to `count` pushed screens from the top-most stack and returns how many it
    /// removed. It never dismisses a sheet; use ``dismiss()`` for that.
    @discardableResult
    public func pop(_ count: Int = 1) -> Int {
        var removed = 0
        while removed < count, entries.last?.style == .push {
            entries.removeLast()
            removed += 1
        }
        return removed
    }

    /// Removes every pushed screen of the top-most stack.
    public func popToRoot() {
        pop(entries.count)
    }

    /// Removes the screens above the last entry whose route matches `predicate`, across sheets.
    /// Returns `false`, changing nothing, when no route matches.
    @discardableResult
    public func popTo(where predicate: (R) -> Bool) -> Bool {
        guard let index = entries.lastIndex(where: { predicate($0.route) }) else { return false }
        entries.removeSubrange((index + 1)...)
        return true
    }

    /// Removes the screens above the last occurrence of `route`.
    @discardableResult
    public func popTo(_ route: R) -> Bool {
        popTo { $0 == route }
    }

    /// Dismisses the top-most sheet or full-screen cover with the screens pushed inside it.
    /// Returns `false` when nothing is presented.
    @discardableResult
    public func dismiss() -> Bool {
        guard let index = entries.lastIndex(where: { $0.style.isModal }) else { return false }
        entries.removeSubrange(index...)
        return true
    }

    /// Dismisses every sheet and full-screen cover; the root stack stays as it is.
    public func dismissAll() {
        guard let index = entries.firstIndex(where: { $0.style.isModal }) else { return }
        entries.removeSubrange(index...)
    }

    /// Dismisses everything and pops to the root view.
    public func reset() {
        entries = []
    }

    // MARK: The transition

    /// Moves to `target`, checking every entry after the part it shares with the current state.
    func transition(to target: [RouteEntry<R>]) -> NavigationOutcome {
        guard target.count <= maxDepth else { return .rejected(.depthLimitExceeded(limit: maxDepth)) }
        let current = entries
        let shared = zip(current, target).prefix { $0 == $1 }.count
        guard let objection = firstObjection(in: target, after: shared, current: current) else {
            entries = target
            return .applied
        }
        switch objection.decision {
        case .allow, .cancel:
            return .cancelled
        case .redirect(let fallback):
            let redirected = Array(target[..<objection.index]) + fallback
            guard redirected.count <= maxDepth else { return .rejected(.depthLimitExceeded(limit: maxDepth)) }
            pending = target
            entries = redirected
            return .redirected
        }
    }

    /// The first entry from `start` on that a guard does not allow, and what that guard decided.
    private func firstObjection(
        in target: [RouteEntry<R>],
        after start: Int,
        current: [RouteEntry<R>]
    ) -> (index: Int, decision: GuardDecision<R>)? {
        for index in target.indices.dropFirst(start) {
            let context = GuardContext(current: current, target: target, index: index)
            for routeGuard in guards {
                let decision = routeGuard.decide(target[index], context)
                if case .allow = decision { continue }
                return (index, decision)
            }
        }
        return nil
    }

    // MARK: Levels, for the views

    /// The positions of the entries that start a sheet or full-screen cover.
    var modalStarts: [Int] {
        entries.indices.filter { entries[$0].style.isModal }
    }

    /// The range of entries pushed on the stack of `level` (0 is the root stack).
    func pushRange(atLevel level: Int) -> Range<Int> {
        let starts = modalStarts
        let lower = level == 0 ? 0 : starts[level - 1] + 1
        let upper = level < starts.count ? starts[level] : entries.count
        return lower..<upper
    }

    /// The pushed routes of `level`.
    func pushes(atLevel level: Int) -> [R] {
        _ = refusals
        guard level <= modalStarts.count else { return [] }
        return entries[pushRange(atLevel: level)].map(\.route)
    }

    /// Called when SwiftUI changes the stack of `level`: the back button, the swipe back or a
    /// `NavigationLink(value:)`. Levels above it are dismissed.
    func setPushes(_ routes: [R], atLevel level: Int) {
        guard level <= modalStarts.count else { return }
        let lower = pushRange(atLevel: level).lowerBound
        let target = Array(entries[..<lower]) + routes.map(RouteEntry.push)
        guard target != entries else { return }
        let outcome = transition(to: target)
        if outcome != .applied { refusals &+= 1 }
    }

    /// The entry that starts modal `level` (1 is the first sheet), if it is shown.
    func modalEntry(atLevel level: Int) -> RouteEntry<R>? {
        let starts = modalStarts
        guard level >= 1, level <= starts.count else { return nil }
        return entries[starts[level - 1]]
    }

    /// Called when SwiftUI dismisses modal `level`, for example by a swipe down.
    func dismissLevel(_ level: Int) {
        let starts = modalStarts
        guard level >= 1, level <= starts.count else { return }
        entries.removeSubrange(starts[level - 1]...)
    }
}
