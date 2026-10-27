// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftRouter",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftRouter", targets: ["SwiftRouter"])
    ],
    targets: [
        .target(
            name: "SwiftRouter",
            path: "Sources/SwiftRouter"
        ),
        .testTarget(
            name: "SwiftRouterTests",
            dependencies: ["SwiftRouter"],
            path: "Tests/SwiftRouterTests"
        )
    ]
)
