// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CustomRepeatDate",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "CustomRepeatDate",
            targets: ["CustomRepeatDate"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CustomRepeatDate",
            dependencies: []
        ),
        .testTarget(
            name: "CustomRepeatDateTests",
            dependencies: ["CustomRepeatDate"]
        ),
    ]
)
