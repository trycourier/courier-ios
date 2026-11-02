// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// This requires Xcode 16 or newer. A Package@swift-5.9.swift used to let Xcode 15 resolve the
// package in the Swift 5 language mode, but Xcode 15 can no longer submit to the App Store, and an
// unenforced second manifest silently drifts from this one -- a target or resource added here and
// forgotten there changes what consumers resolve depending on their toolchain.
//
// CocoaPods consumers can still build the sources in either language mode; see swift_versions in
// Courier_iOS.podspec.

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
    ],
    swiftLanguageModes: [.v6]
)
