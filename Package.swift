// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Courier_iOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Courier_iOS",
            targets: ["Courier_iOS"]
        )
    ],
    targets: [
        .target(
            name: "Courier_iOS",
            resources: [
                Resource.process("Media.xcassets")
            ]
        ),
        .testTarget(
            name: "CourierTests",
            dependencies: ["Courier_iOS"]
        ),
    ]
)
