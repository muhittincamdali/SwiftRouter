/// What a ``RouteGuard`` decides about a route the router is about to show.
public enum GuardDecision<R: Route>: Sendable {
    /// Show the route.
    case allow
    /// Leave the navigation state as it is.
    case cancel
    /// Show these entries instead of the route and everything after it.
    ///
    /// The router keeps the original request as ``Router/pending`` so that it can be resumed
    /// later with ``Router/resumePending()``, for example after the user signs in.
    case redirect([RouteEntry<R>])
}

/// The navigation state a guard sees while it checks an entry.
public struct GuardContext<R: Route>: Sendable {
    /// The entries shown before the change.
    public let current: [RouteEntry<R>]
    /// The complete list of entries the change asks for.
    public let target: [RouteEntry<R>]
    /// The position of the checked entry in ``target``.
    public let index: Int
}

/// A check that runs before the router shows a route.
///
/// Guards run, in the order they were added, for every entry a change adds: a push, a
/// presentation, a deep link, a restored snapshot or a `NavigationLink` inside a ``RouterView``.
/// Entries that are already shown are not checked again unless you call
/// ``Router/revalidate()``. Popping and dismissing are never checked.
///
/// ```swift
/// router.addGuard(.requiring({ session.isSignedIn },
///                            for: { $0.needsAccount },
///                            otherwise: [.sheet(.signIn)]))
/// ```
///
/// Guards are synchronous on purpose: navigation happens in the same update as the tap that
/// caused it, and no screen is shown before its guard has answered.
public struct RouteGuard<R: Route>: Sendable {
    /// A name for the guard, used in your own debugging.
    public let name: String
    let decide: @MainActor @Sendable (RouteEntry<R>, GuardContext<R>) -> GuardDecision<R>

    /// Creates a guard from a closure.
    public init(
        _ name: String,
        decide: @escaping @MainActor @Sendable (_ entry: RouteEntry<R>, _ context: GuardContext<R>) -> GuardDecision<R>
    ) {
        self.name = name
        self.decide = decide
    }

    /// A guard that lets the routes matching `routes` through only while `condition` is true,
    /// and shows `fallback` otherwise.
    public static func requiring(
        _ condition: @escaping @MainActor @Sendable () -> Bool,
        for routes: @escaping @Sendable (R) -> Bool,
        otherwise fallback: [RouteEntry<R>],
        name: String = "requiring"
    ) -> RouteGuard {
        RouteGuard(name) { entry, _ in
            guard routes(entry.route), !condition() else { return .allow }
            return .redirect(fallback)
        }
    }
}
