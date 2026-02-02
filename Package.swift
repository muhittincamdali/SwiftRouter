// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftRouter",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftRouter",
            targets: ["SwiftRouter"]
        )
    ],
    targets: [
        .target(
            name: "SwiftRouter",
            path: "Sources/SwiftRouter",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftRouterTests",
            dependencies: ["SwiftRouter"],
            path: "Tests/SwiftRouterTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
