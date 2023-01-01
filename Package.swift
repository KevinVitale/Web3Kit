// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3Kit",
    platforms: [
      .macOS(.v10_15),
    ],
    products: [
      .library(name: "Web3Kit", targets: ["Web3Kit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.7"),
        .package(url: "https://github.com/KevinVitale/Wei.git", branch: "leif-ibsen/BigInt"),
    ],
    targets: [
        .target(name: "Web3Kit", dependencies: [
            "AnyCodable",
            "Wei",
        ]),
        .testTarget(name: "Web3KitTests", dependencies: ["Web3Kit"]),
    ]
)

