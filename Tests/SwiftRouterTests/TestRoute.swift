import SwiftRouter
import SwiftUI

/// The routes the tests navigate between.
enum TestRoute: Route, Codable {
    case catalog
    case product(Int)
    case reviews(Int)
    case account
    case orders
    case signIn
    case settings

    var needsAccount: Bool {
        switch self {
        case .account, .orders: true
        default: false
        }
    }

    func view() -> some View {
        Text(String(describing: self))
    }
}

/// A mutable sign-in flag that guards read on the main actor.
@MainActor
final class Session {
    var isSignedIn = false
}

/// A switch a test turns on while a guard reads it.
@MainActor
final class Flag {
    var isOn = false
}

extension RouteGuard where R == TestRoute {
    /// Sends account screens to the sign-in sheet while signed out.
    @MainActor
    static func account(_ session: Session) -> RouteGuard<TestRoute> {
        .requiring({ session.isSignedIn }, for: { $0.needsAccount }, otherwise: [.sheet(.signIn)], name: "account")
    }
}
