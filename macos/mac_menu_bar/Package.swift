// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mac_menu_bar",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "mac-menu-bar", targets: ["mac_menu_bar"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "mac_menu_bar",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/mac_menu_bar"
        )
    ]
)
