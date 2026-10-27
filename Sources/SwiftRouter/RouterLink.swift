import SwiftUI

/// A button that pushes or presents a route on the ``Router`` of the surrounding ``RouterView``.
///
/// ```swift
/// RouterLink("Settings", to: AppRoute.settings)
/// RouterLink(to: AppRoute.cart, style: .sheet) {
///     Label("Cart", systemImage: "cart")
/// }
/// ```
///
/// The route goes through the router's guards, like ``Router/push(_:)``. Use it inside a
/// ``RouterView``; outside one there is no router to read and SwiftUI stops the app.
public struct RouterLink<R: Route, Label: View>: View {
    @Environment(Router<R>.self) private var router
    private let route: R
    private let style: PresentationStyle
    private let label: Label

    /// Creates a link with a custom label.
    public init(to route: R, style: PresentationStyle = .push, @ViewBuilder label: () -> Label) {
        self.route = route
        self.style = style
        self.label = label()
    }

    public var body: some View {
        Button {
            if style == .push {
                router.push(route)
            } else {
                router.present(route, style: style)
            }
        } label: {
            label
        }
    }
}

extension RouterLink where Label == Text {
    /// Creates a link with a text label.
    public init(_ title: LocalizedStringKey, to route: R, style: PresentationStyle = .push) {
        self.init(to: route, style: style) { Text(title) }
    }
}

extension View {
    /// Opens the deep links the app receives: URLs from `onOpenURL` (custom schemes) and web
    /// URLs from `onContinueUserActivity` (universal links).
    ///
    /// ```swift
    /// RouterView(router: router) { HomeScreen() }
    ///     .onDeepLink(links, router: router)
    /// ```
    ///
    /// - Parameters:
    ///   - links: The patterns to match the URLs against.
    ///   - router: The router that shows the matched state.
    ///   - perform: Called with each URL and its outcome, for example to open an unmatched web
    ///     link in the browser.
    public func onDeepLink<R: Route>(
        _ links: DeepLinks<R>,
        router: Router<R>,
        perform: (@MainActor (URL, DeepLinkOutcome) -> Void)? = nil
    ) -> some View {
        modifier(DeepLinkReceiver { url in
            let outcome = router.open(url, using: links)
            perform?(url, outcome)
        })
    }
}

/// Receives URLs from both delivery paths and forwards them to one handler.
struct DeepLinkReceiver: ViewModifier {
    let handle: @MainActor (URL) -> Void

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in handle(url) }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                if let url = activity.webpageURL { handle(url) }
            }
    }
}
