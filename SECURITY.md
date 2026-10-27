# Security policy

SwiftRouter reads deep links, which come from outside the app, and runs guards that decide which
screens a user may see. A way around either is a vulnerability.

## In scope

- A URL that reaches a pattern handler although the
  [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
  article says it is refused: a host that is not listed, a scheme other than `https` or a listed
  custom scheme, a user name or password, a `.` or `..` segment in any spelling, a control or
  bidirectional formatting character, or bytes that are not UTF-8.
- A path segment that arrives split or joined differently from the URL, for example through
  `%2F`, so that a pattern or a guard sees another route than the link names.
- A screen shown without its guard being asked: through a push, a presentation, a deep link, a
  restored snapshot, a `NavigationLink`, a tab or the pending request.
- Input that makes the package crash, hang or use memory without bound: a URL, a snapshot, or a
  value read with `int`, `double` or `value(_:as:)`.
- A URL, route or parameter written to the console or a log by the package.

What a guard decides is up to the app; a guard that allows a route it should not is a bug in that
guard, not in the package.

## Supported versions

Security fixes are made for the latest release. 1.x is no longer maintained.

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include the version (tag or commit), the URL, snapshot or navigation calls that show the problem,
and what you expected to happen.

## What happens next

- You get a reply within 7 days confirming that the report arrived.
- The issue is confirmed, fixed with a test that reproduces it, and released together with a
  GitHub security advisory on a disclosure date agreed with you.
- You are credited in the advisory unless you prefer not to be.
