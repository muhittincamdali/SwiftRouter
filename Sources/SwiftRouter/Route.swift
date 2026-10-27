import SwiftUI

/// A screen your app can navigate to.
///
/// Make an enum with one case per screen and return the screen's view from ``view()``:
///
/// ```swift
/// enum AppRoute: Route {
///     case product(id: Int)
///     case settings
///
///     @ViewBuilder
///     func view() -> some View {
///         switch self {
///         case .product(let id): ProductScreen(id: id)
///         case .settings: SettingsScreen()
///         }
///     }
/// }
/// ```
///
/// A route is a value: it is `Hashable`, so the router can compare stacks, and `Sendable`, so it
/// can cross tasks. Add `Codable` to save and restore the navigation state
/// (see ``Router/snapshotData()``).
public protocol Route: Hashable, Sendable {
    /// The type of view the route shows.
    associatedtype Content: View

    /// Returns the view for this route.
    @ViewBuilder @MainActor func view() -> Content
}

/// How a route is shown on top of the screen below it.
public enum PresentationStyle: String, Hashable, Sendable, Codable, CaseIterable {
    /// Pushed onto the current navigation stack.
    case push
    /// Presented as a sheet with its own navigation stack.
    case sheet
    /// Presented over the whole screen with its own navigation stack.
    ///
    /// macOS has no full-screen cover; there the route is presented as a sheet.
    case fullScreenCover

    /// Whether the style starts a new modal level with its own navigation stack.
    public var isModal: Bool { self != .push }
}

/// One step in the navigation state: a route and how it is shown.
///
/// The router keeps an array of entries. Pushed entries stack inside the current modal level; a
/// sheet or full-screen cover starts a new level whose first route is the root of a new
/// navigation stack.
public struct RouteEntry<R: Route>: Hashable, Sendable {
    /// The route.
    public var route: R
    /// How the route is shown.
    public var style: PresentationStyle

    /// Creates an entry.
    public init(_ route: R, style: PresentationStyle = .push) {
        self.route = route
        self.style = style
    }

    /// An entry that pushes `route`.
    public static func push(_ route: R) -> RouteEntry { RouteEntry(route, style: .push) }

    /// An entry that presents `route` as a sheet.
    public static func sheet(_ route: R) -> RouteEntry { RouteEntry(route, style: .sheet) }

    /// An entry that presents `route` over the whole screen.
    public static func fullScreenCover(_ route: R) -> RouteEntry { RouteEntry(route, style: .fullScreenCover) }
}

extension RouteEntry: Codable where R: Codable {}
