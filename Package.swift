// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "CustomRepeatDate",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "CustomRepeatDate",
            targets: ["CustomRepeatDate"]
        ),
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
