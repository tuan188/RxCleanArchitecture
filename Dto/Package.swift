// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dto",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Dto",
            targets: ["Dto"]),
    ],
    dependencies: [
         .package(url: "https://github.com/tuan188/ValidatedPropertyKit.git", from: "0.0.7"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Dto",
            dependencies: [
                .product(name: "ValidatedPropertyKit", package: "ValidatedPropertyKit")
            ]
        )
    ]
)
