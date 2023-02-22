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
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.7")
    ],
    targets: [
        .target(
            name: "Courier",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios")
            ]
        ),
        .testTarget(
            name: "CourierTests",
            dependencies: ["Courier"]
        ),
    ]
)
