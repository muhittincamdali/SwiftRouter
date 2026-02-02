// RouteParameter.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Route Parameter Value

/// A type-safe value that can be stored in route parameters.
///
/// ``RouteParameterValue`` supports common primitive types and provides
/// convenient conversion methods between them.
public enum RouteParameterValue: Sendable, Equatable, CustomStringConvertible {

    /// A string value.
    case string(String)

    /// An integer value.
    case integer(Int)

    /// A floating-point value.
    case double(Double)

    /// A boolean value.
    case boolean(Bool)

    /// A UUID value.
    case uuid(UUID)

    /// A date value.
    case date(Date)

    /// An array of string values.
    case array([String])

    /// The value represented as a string.
    public var stringValue: String {
        switch self {
        case .string(let value): return value
        case .integer(let value): return "\(value)"
        case .double(let value): return "\(value)"
        case .boolean(let value): return "\(value)"
        case .uuid(let value): return value.uuidString
        case .date(let value): return ISO8601DateFormatter().string(from: value)
        case .array(let value): return value.joined(separator: ",")
        }
    }

    /// Attempts to get the value as an integer.
    public var intValue: Int? {
        switch self {
        case .integer(let value): return value
        case .string(let value): return Int(value)
        case .double(let value): return Int(value)
        case .boolean(let value): return value ? 1 : 0
        default: return nil
        }
    }

    /// Attempts to get the value as a double.
    public var doubleValue: Double? {
        switch self {
        case .double(let value): return value
        case .integer(let value): return Double(value)
        case .string(let value): return Double(value)
        default: return nil
        }
    }

    /// Attempts to get the value as a boolean.
    public var boolValue: Bool? {
        switch self {
        case .boolean(let value): return value
        case .string(let value): return Bool(value)
        case .integer(let value): return value != 0
        default: return nil
        }
    }

    /// Attempts to get the value as a UUID.
    public var uuidValue: UUID? {
        switch self {
        case .uuid(let value): return value
        case .string(let value): return UUID(uuidString: value)
        default: return nil
        }
    }

    public var description: String { stringValue }

    public static func == (lhs: RouteParameterValue, rhs: RouteParameterValue) -> Bool {
        lhs.stringValue == rhs.stringValue
    }

    /// Creates a parameter value by inferring the type from a raw string.
    ///
    /// Attempts to parse as integer, double, boolean, or UUID before falling
    /// back to a plain string.
    ///
    /// - Parameter rawValue: The raw string value.
    /// - Returns: A typed ``RouteParameterValue``.
    public static func inferred(from rawValue: String) -> RouteParameterValue {
        if let intVal = Int(rawValue) {
            return .integer(intVal)
        }
        if let doubleVal = Double(rawValue), rawValue.contains(".") {
            return .double(doubleVal)
        }
        if rawValue.lowercased() == "true" || rawValue.lowercased() == "false" {
            return .boolean(rawValue.lowercased() == "true")
        }
        if let uuid = UUID(uuidString: rawValue) {
            return .uuid(uuid)
        }
        return .string(rawValue)
    }
}

// MARK: - Route Parameters

/// A container for route parameter key-value pairs.
///
/// ``RouteParameters`` provides type-safe access to parameter values extracted
/// from route patterns and URL paths.
///
/// ## Usage
///
/// ```swift
/// let params = RouteParameters([
///     "userId": .string("42"),
///     "active": .boolean(true)
/// ])
///
/// let userId = params.string(for: "userId") // "42"
/// let active = params.bool(for: "active")    // true
/// ```
public struct RouteParameters: Sendable, Equatable {

    /// The raw parameter dictionary.
    public let values: [String: RouteParameterValue]

    /// Creates route parameters from a dictionary.
    ///
    /// - Parameter values: The parameter dictionary.
    public init(_ values: [String: RouteParameterValue] = [:]) {
        self.values = values
    }

    /// Whether the parameters collection is empty.
    public var isEmpty: Bool { values.isEmpty }

    /// The number of parameters.
    public var count: Int { values.count }

    /// All parameter keys.
    public var keys: [String] { Array(values.keys) }

    // MARK: - Typed Accessors

    /// Gets a string parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The string value, or `nil`.
    public func string(for key: String) -> String? {
        values[key]?.stringValue
    }

    /// Gets an integer parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The integer value, or `nil`.
    public func integer(for key: String) -> Int? {
        values[key]?.intValue
    }

    /// Gets a double parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The double value, or `nil`.
    public func double(for key: String) -> Double? {
        values[key]?.doubleValue
    }

    /// Gets a boolean parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The boolean value, or `nil`.
    public func bool(for key: String) -> Bool? {
        values[key]?.boolValue
    }

    /// Gets a UUID parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The UUID value, or `nil`.
    public func uuid(for key: String) -> UUID? {
        values[key]?.uuidValue
    }

    /// Gets the raw parameter value.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: The ``RouteParameterValue``, or `nil`.
    public func value(for key: String) -> RouteParameterValue? {
        values[key]
    }

    /// Checks whether a parameter exists.
    ///
    /// - Parameter key: The parameter key.
    /// - Returns: `true` if the key exists.
    public func contains(key: String) -> Bool {
        values[key] != nil
    }

    // MARK: - Merging

    /// Creates new parameters by merging with another set.
    ///
    /// Values from `other` take precedence for duplicate keys.
    ///
    /// - Parameter other: The parameters to merge in.
    /// - Returns: A new ``RouteParameters`` with merged values.
    public func merging(with other: RouteParameters) -> RouteParameters {
        RouteParameters(values.merging(other.values) { _, new in new })
    }

    /// Creates new parameters by adding a single key-value pair.
    ///
    /// - Parameters:
    ///   - key: The parameter key.
    ///   - value: The parameter value.
    /// - Returns: A new ``RouteParameters`` with the added value.
    public func adding(key: String, value: RouteParameterValue) -> RouteParameters {
        var newValues = values
        newValues[key] = value
        return RouteParameters(newValues)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension RouteParameters: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, RouteParameterValue)...) {
        var dict: [String: RouteParameterValue] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self.init(dict)
    }
}
