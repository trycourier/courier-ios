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
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.5.0")
    ],
    targets: [
        .target(
            name: "Courier",
            dependencies: [
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            exclude: [
                "Example",
                "add-swift-package.gif",
                "Contributing.md",
                "env-setup.sh",
                "EnvSample.swift",
                "push-notification-entitlement.gif",
                "release.gif",
                "service-extension-tutorial.gif"
            ],
            resources: [
                Resource.process("Media.xcassets")
            ]
        ),
        .testTarget(
            name: "CourierTests",
            dependencies: ["Courier"]
        ),
    ]
)
