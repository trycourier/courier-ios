// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Courier",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Courier",
            targets: ["Courier"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Courier",
            dependencies: []
        ),
        .testTarget(
            name: "CourierTests",
            dependencies: ["Courier"]
        ),
    ]
)
