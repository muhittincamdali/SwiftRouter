# Contributing

Thanks for taking the time to improve SwiftRouter.

## Reporting bugs

Open an issue with:

- what you did and what happened: the navigation calls, the deep link or the taps, and the
  screens you expected,
- the platform and OS version (simulator or device) and the Xcode version,
- a small route enum and view that show the problem, if you can.

A deep link that gets past the checks described in the
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
article, or a screen that a guard should have stopped, is a security issue: report it privately
as described in [SECURITY.md](SECURITY.md), not in a public issue.

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change, with tests for the logic it changes.
3. Run the tests on macOS and on an iPhone simulator:

    ```sh
    swift test
    xcodebuild test -scheme SwiftRouter \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

4. If you change navigation behaviour, run the example app's UI tests as well:

    ```sh
    cd Examples/RouterDemo
    xcodebuild test -scheme RouterDemo \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

5. If you change a README code sample, change the copy in
   `Examples/RouterDemo/RouterDemo/ReadmeSamples.swift` as well. That file is what gets
   compiled: by the example app, and by `swift test` through the link
   `Tests/SwiftRouterTests/ReadmeSamples.swift`.
6. If the example app looks different after your change, recapture the README screenshots with
   `scripts/capture-screens.sh`.
7. `README.md` has translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI fails while a translation is behind. If you change `README.md`
   and cannot update the translations, say so in the pull request and they will be updated
   before it is merged.

Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages, for example
`fix(deeplinks): refuse an empty host`.

## Where things are

| Path | Contents |
| --- | --- |
| `Sources/SwiftRouter/Router.swift` | The navigation state, the transitions and the guard checks |
| `Sources/SwiftRouter/RouterView.swift` | The SwiftUI views that show the state |
| `Sources/SwiftRouter/DeepLinks.swift`, `URLPattern.swift` | Link checks, pattern matching and building |
| `Sources/SwiftRouter/TabRouter.swift`, `RouterSnapshot.swift` | Tabs and saved state |
| `Sources/SwiftRouter/SwiftRouter.docc` | The documentation catalog |
| `Tests/SwiftRouterTests` | Swift Testing tests |
| `Examples/RouterDemo` | The example app (XcodeGen spec in `project.yml`) and its UI tests |

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
