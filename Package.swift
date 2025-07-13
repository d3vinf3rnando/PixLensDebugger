// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixLensDebugger",
    platforms: [
        .iOS(.v13) // ✅ This is CRITICAL to enable UIKit
    ],
    products: [
        .library(
            name: "PixLensDebugger",
            targets: ["PixLensDebugger"]
        )
    ],
    targets: [
        .target(
            name: "PixLensDebugger",
            path: "Sources/PixLensDebugger"
        ),
        .testTarget(
            name: "PixLensDebuggerTests",
            dependencies: ["PixLensDebugger"],
            path: "Tests/PixLensDebuggerTests"
        )
    ]
)
