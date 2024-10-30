// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxCleanArchitecture",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RxCleanArchitecture",
            targets: ["RxCleanArchitecture"]),
        .library(
            name: "CoreDataRepository",
            targets: ["CoreDataRepository"]),
        .library(
            name: "PagingTableView",
            targets: ["PagingTableView"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/JohnEstropia/CoreStore.git", from: "9.2.0"),
        .package(url: "https://github.com/eggswift/pull-to-refresh", from: "2.9.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RxCleanArchitecture",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "RxCleanArchitecture/Sources"
        ),
        .target(
            name: "CoreDataRepository",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "CoreStore", package: "CoreStore")
            ],
            path: "CoreDataRepository/Sources"
        ),
        .target(
            name: "PagingTableView",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "ESPullToRefresh", package: "pull-to-refresh")
            ],
            path: "PagingTableView/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)

