import Foundation

/// Why a URL pattern is invalid, or why a path cannot be built from it.
public enum URLPatternError: Error, Hashable, Sendable {
    /// The pattern does not start with `/`.
    case missingLeadingSlash
    /// A parameter has no name, or a name with characters other than letters, digits and `_`.
    case invalidParameterName(String)
    /// Two parameters have the same name.
    case duplicateParameter(String)
    /// `*` is not the last segment.
    case wildcardNotLast
    /// An optional parameter is followed by another segment.
    case optionalParameterNotLast(String)
    /// A literal segment is `.` or `..`, or contains a control character.
    case invalidLiteral(String)
    /// A required parameter has no value.
    case missingValue(String)
    /// A value is empty, `.` or `..`, or contains a control character, so it could not be read back.
    case invalidValue(name: String)
}

/// A path pattern such as `/products/:id`, matched against the segments of a URL path.
///
/// | Segment | Matches |
/// | --- | --- |
/// | `products` | exactly that segment |
/// | `:id` | any one segment, read as the parameter `id` |
/// | `:tab?` | one segment or none, only as the last segment |
/// | `*` | all remaining segments, only as the last segment |
///
/// Segments are compared after percent-decoding, so `%2F` stays inside one segment and can never
/// start a new one.
public struct URLPattern: Hashable, Sendable, CustomStringConvertible {
    /// One segment of a pattern.
    public enum Segment: Hashable, Sendable {
        /// A fixed segment.
        case literal(String)
        /// A named segment.
        case parameter(String)
        /// A named segment that may be missing at the end of the path.
        case optionalParameter(String)
        /// The remaining segments.
        case wildcard
    }

    /// How literal segments are compared.
    public enum LiteralMatching: Hashable, Sendable {
        /// Letter case must match, as in URL paths.
        case exact
        /// Letter case is ignored.
        case caseInsensitive
    }

    /// The segments, in order.
    public let segments: [Segment]
    /// The pattern as written.
    public let description: String

    /// Parses a pattern.
    public init(_ pattern: String) throws(URLPatternError) {
        guard pattern.hasPrefix("/") else { throw .missingLeadingSlash }
        var parsed: [Segment] = []
        var names: Set<String> = []
        let parts = pattern.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        for (position, part) in parts.enumerated() {
            let isLast = position == parts.count - 1
            let segment = try Self.segment(from: part)
            switch segment {
            case .wildcard where !isLast:
                throw .wildcardNotLast
            case .optionalParameter(let name) where !isLast:
                throw .optionalParameterNotLast(name)
            case .parameter(let name), .optionalParameter(let name):
                guard names.insert(name).inserted else { throw .duplicateParameter(name) }
            default:
                break
            }
            parsed.append(segment)
        }
        segments = parsed
        description = pattern
    }

    private static func segment(from part: String) throws(URLPatternError) -> Segment {
        if part == "*" { return .wildcard }
        guard part.hasPrefix(":") else {
            guard PathText.isAllowedSegment(part) else { throw .invalidLiteral(part) }
            return .literal(part)
        }
        var name = String(part.dropFirst())
        let isOptional = name.hasSuffix("?")
        if isOptional { name.removeLast() }
        guard Self.isValidName(name) else { throw .invalidParameterName(name) }
        return isOptional ? .optionalParameter(name) : .parameter(name)
    }

    private static func isValidName(_ name: String) -> Bool {
        func isLetter(_ scalar: Unicode.Scalar) -> Bool {
            ("a"..."z").contains(scalar) || ("A"..."Z").contains(scalar) || scalar == "_"
        }
        guard let first = name.unicodeScalars.first, isLetter(first) else { return false }
        return name.unicodeScalars.allSatisfy { isLetter($0) || ("0"..."9").contains($0) }
    }

    /// Matches decoded path segments. Returns the parameters and the segments the wildcard
    /// took, or `nil` when the path does not match.
    public func match(
        _ path: [String],
        literalMatching: LiteralMatching = .exact
    ) -> (parameters: [String: String], rest: [String])? {
        var parameters: [String: String] = [:]
        var position = 0
        for segment in segments {
            switch segment {
            case .literal(let literal):
                guard position < path.count, Self.equal(literal, path[position], literalMatching) else { return nil }
                position += 1
            case .parameter(let name):
                guard position < path.count else { return nil }
                parameters[name] = path[position]
                position += 1
            case .optionalParameter(let name):
                if position < path.count {
                    parameters[name] = path[position]
                    position += 1
                }
            case .wildcard:
                return (parameters, Array(path[position...]))
            }
        }
        return position == path.count ? (parameters, []) : nil
    }

    private static func equal(_ literal: String, _ segment: String, _ matching: LiteralMatching) -> Bool {
        switch matching {
        case .exact: literal == segment
        case .caseInsensitive: literal.caseInsensitiveCompare(segment) == .orderedSame
        }
    }

    /// Builds a percent-encoded path from parameter values; the reverse of ``match(_:literalMatching:)``.
    ///
    /// ```swift
    /// try URLPattern("/products/:id").path(with: ["id": "42"])  // "/products/42"
    /// ```
    public func path(with values: [String: String], rest: [String] = []) throws(URLPatternError) -> String {
        var parts: [String] = []
        for segment in segments {
            switch segment {
            case .literal(let literal):
                parts.append(PathText.encode(literal))
            case .parameter(let name):
                guard let value = values[name] else { throw .missingValue(name) }
                parts.append(try Self.encoded(value, name: name))
            case .optionalParameter(let name):
                if let value = values[name] { parts.append(try Self.encoded(value, name: name)) }
            case .wildcard:
                for value in rest { parts.append(try Self.encoded(value, name: "*")) }
            }
        }
        return "/" + parts.joined(separator: "/")
    }

    private static func encoded(_ value: String, name: String) throws(URLPatternError) -> String {
        guard !value.isEmpty, PathText.isAllowedSegment(value) else { throw .invalidValue(name: name) }
        return PathText.encode(value)
    }

    /// Orders patterns from the most to the least specific: without a wildcard first, then by
    /// the number of literal, required and optional segments.
    var specificity: [Int] {
        var literals = 0, required = 0, optional = 0, wildcard = 0
        for segment in segments {
            switch segment {
            case .literal: literals += 1
            case .parameter: required += 1
            case .optionalParameter: optional += 1
            case .wildcard: wildcard = 1
            }
        }
        return [1 - wildcard, literals, required, optional]
    }
}

/// Rules for the text of one path segment, shared by patterns and URL parsing.
enum PathText {
    /// RFC 3986 unreserved characters; everything else is percent-encoded.
    private static let unreserved = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    static func encode(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: unreserved) ?? text
    }

    /// A segment is allowed unless it is a dot segment or contains a control character.
    static func isAllowedSegment(_ text: String) -> Bool {
        text != "." && text != ".." && !containsControlCharacter(text)
    }

    /// C0 and C1 control characters, DEL, and the bidirectional formatting characters that can
    /// make a displayed value read differently from the stored one.
    static func containsControlCharacter(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x00...0x1F, 0x7F...0x9F, 0x200E, 0x200F, 0x202A...0x202E, 0x2066...0x2069: true
            default: false
            }
        }
    }
}
