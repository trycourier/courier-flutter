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
        // Swift Package Manager gets every Courier_iOS release. The podspec stays on 6.0.10, the last
        // version on CocoaPods trunk, so the two pins differ once a newer Courier_iOS ships.
        .package(url: "https://github.com/trycourier/courier-ios", exact: "6.0.10")
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
