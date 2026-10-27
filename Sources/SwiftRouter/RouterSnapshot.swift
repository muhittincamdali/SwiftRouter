import SwiftUI

/// The saved navigation state of a ``Router`` whose routes are `Codable`.
public struct RouterSnapshot<R: Route & Codable>: Codable, Hashable, Sendable {
    /// The format version this package writes.
    public static var currentVersion: Int { 1 }

    /// The format version of the snapshot.
    public var version: Int
    /// The entries, from the bottom of the root stack up.
    public var entries: [RouteEntry<R>]

    /// Creates a snapshot of the current format.
    public init(entries: [RouteEntry<R>]) {
        self.version = Self.currentVersion
        self.entries = entries
    }
}

/// Why a snapshot could not be restored. The router keeps its state when restoring fails.
public enum RestorationError: Error, Hashable, Sendable {
    /// The data is larger than ``Router/maxSnapshotSize``.
    case tooLarge(limit: Int)
    /// The data was written by a format version this package does not read.
    case unsupportedVersion(Int)
    /// The data is not a snapshot of these routes.
    case unreadable
}

extension Router where R: Codable {
    /// The largest snapshot ``restore(from:)`` reads: 256 KiB.
    public static var maxSnapshotSize: Int { 256 * 1_024 }

    /// The current entries as JSON.
    public func snapshotData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(RouterSnapshot(entries: entries))
    }

    /// Replaces the state with a snapshot from ``snapshotData()``.
    ///
    /// The restored entries go through the guards, so a screen saved while the user was signed
    /// in is not shown after they signed out. A snapshot longer than ``maxDepth`` is rejected.
    @discardableResult
    public func restore(from data: Data) throws(RestorationError) -> NavigationOutcome {
        guard data.count <= Self.maxSnapshotSize else { throw .tooLarge(limit: Self.maxSnapshotSize) }
        let snapshot: RouterSnapshot<R>
        do {
            snapshot = try JSONDecoder().decode(RouterSnapshot<R>.self, from: data)
        } catch {
            throw .unreadable
        }
        guard snapshot.version == RouterSnapshot<R>.currentVersion else { throw .unsupportedVersion(snapshot.version) }
        return setEntries(snapshot.entries)
    }
}

extension View {
    /// Saves the router's state in the scene's storage and restores it when the scene is
    /// created again, for example after the system ended the app in the background.
    ///
    /// Each window has its own scene storage, so two windows of the same app keep separate
    /// navigation states. Data that cannot be restored is ignored and the router starts at the
    /// root.
    ///
    /// - Parameters:
    ///   - router: The router to save and restore.
    ///   - key: The scene storage key; unique among the routers of one scene.
    public func routerStateRestoration<R: Route & Codable>(_ router: Router<R>, key: String) -> some View {
        modifier(RouterRestoration(router: router, key: key))
    }
}

struct RouterRestoration<R: Route & Codable>: ViewModifier {
    let router: Router<R>
    @SceneStorage private var stored: Data?
    @State private var restored = false

    init(router: Router<R>, key: String) {
        self.router = router
        _stored = SceneStorage(key)
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !restored else { return }
                restored = true
                if let stored { _ = try? router.restore(from: stored) }
            }
            .onChange(of: router.entries) {
                stored = try? router.snapshotData()
            }
    }
}
