import Foundation

/// SwiftRouter: Universal DeepLink Parser
public struct UniversalLinkParser: Sendable {
    public static func parse(url: URL) -> String? {
        return url.path
    }
}
