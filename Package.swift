// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreBluetoothMock-Collection",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreBluetoothMock-Collection",
            targets: ["CoreBluetoothMock-Collection"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
            from: "0.17.0"
        ),
        .package(
            url: "https://github.com/NickKibish/iOS-Bluetooth-Numbers-Database.git",
            from: "1.0.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreBluetoothMock-Collection",
            dependencies: [
                .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock"),
                .product(name: "iOS-Bluetooth-Numbers-Database", package: "iOS-Bluetooth-Numbers-Database")
            ]
        ),
    ]
)
