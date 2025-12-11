// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixLensDebugger",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "PixLensDebugger",
            targets: ["PixLensDebugger"]
        ),
    ],
    targets: [
        .target(
            name: "PixLensDebugger",
            dependencies: [],
            path: "Sources"
        )
    ]
)


///Stable Version Jul 19 2025
///update test