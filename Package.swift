// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "CustomRepeatDate",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "CustomRepeatDate",
            targets: ["CustomRepeatDate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CustomRepeatDate",
            dependencies: []),
        .testTarget(
            name: "CustomRepeatDateTests",
            dependencies: ["CustomRepeatDate"]),
    ]
)
