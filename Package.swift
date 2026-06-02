// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomHLSPlayer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CustomHLSPlayer",
            targets: ["CustomVideoplyer"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "CustomVideoplyer",
            path: "XCFramework/CustomVideoplyer.xcframework"
        )
    ]
)
