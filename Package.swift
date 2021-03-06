// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModularizationHelper",
    platforms: [.macOS(.v11), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ModularizationHelper",
            targets: ["ModularizationHelper"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Mechagnome/BaseUI", .branch("master")),
        .package(url: "https://github.com/Mechagnome/Alliances", .branch("master")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.2.0")),
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMajor(from: "0.31.0")),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ModularizationHelper",
            dependencies: [
                .product(name: "BaseUI", package: "BaseUI"),
                .product(name: "Alliances", package: "Alliances"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "Files", package: "Files"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
            ]),
        .testTarget(
            name: "ModularizationHelperTests",
            dependencies: ["ModularizationHelper"]),
    ]
)
