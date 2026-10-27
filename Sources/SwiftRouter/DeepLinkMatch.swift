import Foundation

/// The values read from a URL that matched a pattern.
///
/// Path parameters are read with ``subscript(_:)`` and the typed accessors such as
/// ``int(_:)``; query items with ``query(_:)``. Every accessor returns `nil` for a value that is
/// missing or does not convert, so a handler can reject the link by returning `nil`.
public struct DeepLinkMatch: Hashable, Sendable {
    /// The pattern that matched.
    public let pattern: URLPattern
    /// The path parameters, percent-decoded.
    public let parameters: [String: String]
    /// The segments taken by a trailing `*`, percent-decoded.
    public let rest: [String]
    /// The query items in URL order, percent-decoded. A name without `=` has an empty value.
    public let queryItems: [QueryItem]

    /// One name and value of the query.
    public struct QueryItem: Hashable, Sendable {
        /// The name.
        public let name: String
        /// The value; empty when the item has no `=`.
        public let value: String
    }

    // MARK: Path parameters

    /// The path parameter `name`.
    public subscript(_ name: String) -> String? { parameters[name] }

    /// The path parameter `name` as an `Int`, or `nil` when it is not a whole number in range.
    public func int(_ name: String) -> Int? { parameters[name].flatMap { Int($0) } }

    /// The path parameter `name` as a finite `Double`; `nan` and `inf` are `nil`.
    public func double(_ name: String) -> Double? { parameters[name].flatMap(Self.finite) }

    /// The path parameter `name` as a `UUID`.
    public func uuid(_ name: String) -> UUID? { parameters[name].flatMap(UUID.init(uuidString:)) }

    /// The path parameter `name` converted with `init?(_ description:)`, such as `Int64` or `Bool`.
    public func value<T: LosslessStringConvertible>(_ name: String, as type: T.Type = T.self) -> T? {
        parameters[name].flatMap(T.init)
    }

    /// The path parameter `name` as a raw-value enum, such as `enum Tab: String`.
    public func value<T: RawRepresentable>(_ name: String, as type: T.Type = T.self) -> T? where T.RawValue == String {
        parameters[name].flatMap(T.init(rawValue:))
    }

    // MARK: Query

    /// The first value of the query item `name`.
    public func query(_ name: String) -> String? {
        queryItems.first { $0.name == name }?.value
    }

    /// Every value of the query item `name`, in URL order.
    public func queryValues(_ name: String) -> [String] {
        queryItems.filter { $0.name == name }.map(\.value)
    }

    /// The first value of the query item `name` as an `Int`.
    public func queryInt(_ name: String) -> Int? { query(name).flatMap { Int($0) } }

    /// The first value of the query item `name` as a finite `Double`.
    public func queryDouble(_ name: String) -> Double? { query(name).flatMap(Self.finite) }

    private static func finite(_ text: String) -> Double? {
        guard let value = Double(text), value.isFinite else { return nil }
        return value
    }
}
