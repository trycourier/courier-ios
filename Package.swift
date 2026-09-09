// swift-tools-version: 6.0
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
            dependencies: ["Courier_iOS"],
            // The test suite is not yet Swift 6 language-mode clean. The shipped
            // library builds in Swift 6 mode; the tests remain in Swift 5 mode
            // until they are migrated separately.
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ],
    swiftLanguageModes: [.v6]
)
