import Foundation

/// Why a URL was refused before any pattern was tried.
public enum DeepLinkRejection: Error, Hashable, Sendable {
    /// The URL is longer than ``DeepLinkLimits/maxURLLength`` bytes.
    case urlTooLong(limit: Int)
    /// The path has more than ``DeepLinkLimits/maxPathSegments`` segments.
    case tooManySegments(limit: Int)
    /// The query has more than ``DeepLinkLimits/maxQueryItems`` items.
    case tooManyQueryItems(limit: Int)
    /// The scheme is neither `https` with an allowed host nor one of the custom schemes.
    case unsupportedScheme
    /// An `https` URL whose host is not in the allowed hosts, is not a plain DNS name or has a
    /// port other than 443.
    case hostNotAllowed
    /// The URL contains a user name or password.
    case credentialsNotAllowed
    /// The text is not a URL, or a path that does not start with `/`.
    case malformedURL
    /// A `%` is not followed by two hex digits, or the bytes are not UTF-8.
    case invalidPercentEncoding
    /// A path segment is `.` or `..` after decoding.
    case dotSegment
    /// A segment, query name or query value contains a control character.
    case controlCharacter
}

/// Bounds on the URLs ``DeepLinks`` reads; a longer URL is rejected before it is parsed further.
public struct DeepLinkLimits: Hashable, Sendable {
    /// The largest URL, in UTF-8 bytes of its absolute string.
    public var maxURLLength: Int
    /// The largest number of path segments, counting the host of a custom-scheme URL.
    public var maxPathSegments: Int
    /// The largest number of query items.
    public var maxQueryItems: Int

    /// Creates limits.
    public init(maxURLLength: Int = 2_048, maxPathSegments: Int = 32, maxQueryItems: Int = 32) {
        self.maxURLLength = maxURLLength
        self.maxPathSegments = maxPathSegments
        self.maxQueryItems = maxQueryItems
    }

    /// 2,048 bytes, 32 segments and 32 query items.
    public static let `default` = DeepLinkLimits()
}

/// What ``DeepLinks/resolve(_:)`` found for a URL.
public enum DeepLinkResolution<R: Route>: Sendable {
    /// A pattern matched and its handler returned these entries.
    case matched([RouteEntry<R>], DeepLinkMatch)
    /// The URL is valid but no pattern matched, or every matching handler returned `nil`.
    case unmatched
    /// The URL was refused.
    case rejected(DeepLinkRejection)
}

/// Maps URLs to navigation states.
///
/// Register one pattern per kind of link. A handler returns the routes to show, from the root
/// stack up, or `nil` when a value in the URL is not acceptable:
///
/// ```swift
/// var links = DeepLinks<AppRoute>(schemes: ["shop"], hosts: ["shop.example.com"])
/// links.add("/products/:id") { match in
///     match.int("id").map { [.catalog, .product(id: $0)] }
/// }
/// links.add("/cart", entries: { _ in [.sheet(.cart)] })
/// ```
///
/// Both `shop://products/42` and `https://shop.example.com/products/42` then show the product.
/// In a custom-scheme URL the host is read as the first path segment.
///
/// The most specific pattern is tried first (see ``URLPattern``); patterns that are equally
/// specific are tried in the order they were added.
public struct DeepLinks<R: Route>: Sendable {
    private struct Rule: Sendable {
        let pattern: URLPattern
        let handler: @Sendable (DeepLinkMatch) -> [RouteEntry<R>]?
    }

    /// The custom schemes accepted, lowercased, such as `shop` for `shop://…`.
    public let schemes: Set<String>
    /// The hosts accepted for `https` links, lowercased. `*.example.com` accepts every subdomain
    /// of `example.com`, but not `example.com` itself. Hosts are compared in their ASCII form, so
    /// list an internationalized name as `xn--…`.
    public let hosts: Set<String>
    /// How literal segments are compared.
    public let literalMatching: URLPattern.LiteralMatching
    /// The bounds on accepted URLs.
    public let limits: DeepLinkLimits

    private var rules: [Rule] = []

    /// Creates an empty map.
    public init(
        schemes: Set<String> = [],
        hosts: Set<String> = [],
        literalMatching: URLPattern.LiteralMatching = .exact,
        limits: DeepLinkLimits = .default
    ) {
        self.schemes = Set(schemes.map { $0.lowercased() })
        self.hosts = Set(hosts.map { HostName.normalized($0) })
        self.literalMatching = literalMatching
        self.limits = limits
    }

    /// The patterns, in the order they are tried.
    public var patterns: [URLPattern] { rules.map(\.pattern) }

    /// Adds a pattern whose handler returns pushed routes.
    ///
    /// The pattern is written by you, so an invalid one stops the app with a message in debug
    /// and release builds. Use ``URLPattern/init(_:)`` to check a pattern that is not.
    public mutating func add(_ pattern: String, _ routes: @escaping @Sendable (DeepLinkMatch) -> [R]?) {
        add(pattern, entries: { match in routes(match)?.map(RouteEntry.push) })
    }

    /// Adds a pattern whose handler returns entries, so it can present sheets and covers.
    public mutating func add(_ pattern: String, entries: @escaping @Sendable (DeepLinkMatch) -> [RouteEntry<R>]?) {
        let parsed: URLPattern
        do {
            parsed = try URLPattern(pattern)
        } catch {
            preconditionFailure("Invalid deep link pattern \"\(pattern)\": \(error)")
        }
        let rule = Rule(pattern: parsed, handler: entries)
        let index = rules.firstIndex { $0.pattern.specificity.lexicographicallyPrecedes(parsed.specificity) } ?? rules.endIndex
        rules.insert(rule, at: index)
    }

    // MARK: Resolving

    /// Finds the entries for a URL.
    public func resolve(_ url: URL) -> DeepLinkResolution<R> {
        let text = url.absoluteString
        guard text.utf8.count <= limits.maxURLLength else { return .rejected(.urlTooLong(limit: limits.maxURLLength)) }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return .rejected(.malformedURL) }
        guard components.percentEncodedUser == nil, components.percentEncodedPassword == nil else {
            return .rejected(.credentialsNotAllowed)
        }
        let scheme = components.scheme?.lowercased() ?? ""
        var leading: [Substring] = []
        if scheme == "https" {
            guard let host = components.encodedHost, isAllowed(host: host) else { return .rejected(.hostNotAllowed) }
            // A port too large for Int leaves `port` nil, so the written port decides, not `port` alone.
            guard components.rangeOfPort == nil || components.port == HostName.httpsPort else {
                return .rejected(.hostNotAllowed)
            }
        } else if schemes.contains(scheme) {
            if let host = components.percentEncodedHost, !host.isEmpty { leading = [Substring(host)] }
        } else {
            return .rejected(.unsupportedScheme)
        }
        return resolve(leading: leading, components: components)
    }

    /// Finds the entries for an in-app path such as `/products/42?ref=push`, for example from a
    /// notification payload. The path must start with `/` and have no scheme or host.
    public func resolve(path: String) -> DeepLinkResolution<R> {
        guard path.utf8.count <= limits.maxURLLength else { return .rejected(.urlTooLong(limit: limits.maxURLLength)) }
        guard path.hasPrefix("/"), !path.hasPrefix("//"),
              let components = URLComponents(string: path),
              components.scheme == nil, components.percentEncodedHost == nil
        else { return .rejected(.malformedURL) }
        return resolve(leading: [], components: components)
    }

    private func resolve(leading: [Substring], components: URLComponents) -> DeepLinkResolution<R> {
        let raw = leading + components.percentEncodedPath.split(separator: "/", omittingEmptySubsequences: true)
        guard raw.count <= limits.maxPathSegments else { return .rejected(.tooManySegments(limit: limits.maxPathSegments)) }
        let segments: [String]
        let query: [DeepLinkMatch.QueryItem]
        do {
            segments = try raw.map(Self.decodeSegment)
            query = try queryItems(components)
        } catch {
            return .rejected(error)
        }
        for rule in rules {
            guard let found = rule.pattern.match(segments, literalMatching: literalMatching) else { continue }
            let match = DeepLinkMatch(pattern: rule.pattern, parameters: found.parameters, rest: found.rest, queryItems: query)
            if let entries = rule.handler(match) { return .matched(entries, match) }
        }
        return .unmatched
    }

    private func queryItems(_ components: URLComponents) throws(DeepLinkRejection) -> [DeepLinkMatch.QueryItem] {
        guard let items = components.percentEncodedQueryItems else { return [] }
        guard items.count <= limits.maxQueryItems else { throw .tooManyQueryItems(limit: limits.maxQueryItems) }
        var decoded: [DeepLinkMatch.QueryItem] = []
        for item in items {
            decoded.append(.init(name: try Self.decode(item.name), value: try Self.decode(item.value ?? "")))
        }
        return decoded
    }

    private static func decodeSegment(_ raw: Substring) throws(DeepLinkRejection) -> String {
        let segment = try decode(String(raw))
        guard segment != ".", segment != ".." else { throw .dotSegment }
        return segment
    }

    private static func decode(_ raw: String) throws(DeepLinkRejection) -> String {
        guard let text = raw.removingPercentEncoding else { throw .invalidPercentEncoding }
        guard !PathText.containsControlCharacter(text) else { throw .controlCharacter }
        return text
    }

    // MARK: Hosts

    /// `rawHost` is the IDNA (ASCII) form. It is never percent-decoded: a decoded `/`, `@` or `.`
    /// would move the label boundary that the `*.` suffix check relies on.
    private func isAllowed(host rawHost: String) -> Bool {
        let host = HostName.normalized(rawHost)
        guard HostName.isDNSName(host) else { return false }
        if hosts.contains(host) { return true }
        return hosts.contains { allowed in
            guard allowed.hasPrefix("*.") else { return false }
            let parent = allowed.dropFirst(1)
            return host.hasSuffix(parent) && host.count > parent.count
        }
    }
}

/// Host name rules for `https` deep links.
enum HostName {
    static let httpsPort = 443
    private static let maxLength = 253
    private static let maxLabelLength = 63
    private static let hyphen = UInt8(ascii: "-")

    /// Lowercased, without the trailing dot of a fully qualified name.
    static func normalized(_ host: String) -> String {
        var host = host.lowercased()
        if host.hasSuffix(".") { host.removeLast() }
        return host
    }

    /// Letters, digits and `-` in labels of 1 to 63 bytes that neither start nor end with `-`.
    static func isDNSName(_ host: String) -> Bool {
        guard !host.isEmpty, host.utf8.count <= maxLength else { return false }
        return host.split(separator: ".", omittingEmptySubsequences: false).allSatisfy { label in
            let bytes = label.utf8
            guard let first = bytes.first, let last = bytes.last, bytes.count <= maxLabelLength else { return false }
            return first != hyphen && last != hyphen && bytes.allSatisfy(isNameByte)
        }
    }

    private static func isNameByte(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte)
            || (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
            || byte == hyphen
    }
}

/// The result of ``Router/open(_:using:)``.
public enum DeepLinkOutcome: Hashable, Sendable {
    /// The URL matched; the navigation outcome says whether the guards let it through.
    case navigated(NavigationOutcome)
    /// No pattern matched; the navigation state did not change.
    case unmatched
    /// The URL was refused; the navigation state did not change.
    case rejected(DeepLinkRejection)
}

extension Router {
    /// Shows the navigation state a URL maps to, replacing the current one.
    ///
    /// The new entries go through the guards like any other navigation.
    @discardableResult
    public func open(_ url: URL, using links: DeepLinks<R>) -> DeepLinkOutcome {
        apply(links.resolve(url))
    }

    /// Shows the navigation state an in-app path maps to, replacing the current one.
    @discardableResult
    public func open(path: String, using links: DeepLinks<R>) -> DeepLinkOutcome {
        apply(links.resolve(path: path))
    }

    private func apply(_ resolution: DeepLinkResolution<R>) -> DeepLinkOutcome {
        switch resolution {
        case .matched(let entries, _): .navigated(setEntries(entries))
        case .unmatched: .unmatched
        case .rejected(let reason): .rejected(reason)
        }
    }
}
