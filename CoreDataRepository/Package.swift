// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataRepository",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreDataRepository",
            targets: ["CoreDataRepository"]),
    ],
    dependencies: [
         .package(url: "https://github.com/JohnEstropia/CoreStore.git", from: "9.2.0"),
         .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreDataRepository",
            dependencies: [
                .product(name: "CoreStore", package: "CoreStore"),
                .product(name: "RxSwift", package: "RxSwift"),
            ]),

    ]
)
