// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxCleanArchitecture",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RxCleanArchitecture",
            targets: ["RxCleanArchitecture"]),
    ],
    dependencies: [
         .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RxCleanArchitecture",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ]),

    ]
)
