// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "time-log-components",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TimeLogComponents",
            targets: ["TimeLogComponents"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-identified-collections",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/dkk/WrappingHStack",
            from: "2.2.11"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TimeLogComponents",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "WrappingHStack", package: "WrappingHStack")
            ]
        ),
        .testTarget(
            name: "TimeLogComponentsTests",
            dependencies: ["TimeLogComponents"]),
    ]
)
