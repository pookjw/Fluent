// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FluentCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FluentCore",
            targets: ["FluentCore"]
        )
    ],
    targets: [
        .target(
            name: "FluentCore",
            publicHeadersPath: "include",
            cSettings: [.unsafeFlags(["-fno-objc-arc", "-fno-objc-weak", "-ICancellable"])]
        ),
        .testTarget(
            name: "FluentCoreTests",
            dependencies: ["FluentCore"],
            cSettings: [.unsafeFlags(["-fno-objc-arc", "-fno-objc-weak"])]
        )
    ]
)
