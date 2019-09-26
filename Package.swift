// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Liquid",
    products: [
        .library(
            name: "Liquid",
            targets: ["Liquid"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Liquid",
            dependencies: []),
        .testTarget(
            name: "LiquidTests",
            dependencies: ["Liquid"]),
    ]
)
