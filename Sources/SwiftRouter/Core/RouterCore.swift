import Foundation
import SwiftUI

/// Main entry point for the SwiftRouter navigation engine.
public enum SwiftRouter {
    public static let version = "2.0.0"
}

/// A type-safe route definition.
public protocol Route: Hashable, Sendable {
    associatedtype Content: View
    @ViewBuilder @MainActor func view() -> Content
}

/// A high-integrity router that manages navigation state.
@MainActor
public final class Router<R: Route>: ObservableObject {
    @Published public var path: [R] = []
    
    public init() {}
    
    public func navigate(to route: R) {
        path.append(route)
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeAll()
    }
}
