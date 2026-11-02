// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "courier_flutter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "courier-flutter", targets: ["courier_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Keep in step with the Courier_iOS pin in courier_flutter.podspec.
        .package(url: "https://github.com/trycourier/courier-ios", exact: "5.9.0")
    ],
    targets: [
        .target(
            name: "courier_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Courier_iOS", package: "courier-ios")
            ]
        )
    ]
)
