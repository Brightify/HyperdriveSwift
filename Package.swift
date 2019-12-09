// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ReactantUI",
    products: [
        .executable(
            name: "hyperdrive",
            targets: ["hyperdrive-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", .upToNextMinor(from: "4.4.0")),
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.5.0")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.2.2"),
    ],
    targets: [
        .target(
            name: "SwiftCodeGen",
            dependencies: [],
            path: "Interface/Sources/SwiftCodeGen",
            swiftSettings: [
                .define("GeneratingInterface"),
            ]),
        .target(
            name: "Common",
            dependencies: [],
            path: "Interface/Sources/Common",
            swiftSettings: [
                .define("GeneratingInterface"),
            ]),
        .target(
            name: "Tokenizer",
            dependencies: ["Common", "SwiftCodeGen"],
            path: "Interface/Sources/Tokenizer",
            swiftSettings: [
                .define("GeneratingInterface"),
            ]),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "XcodeProj", "SwiftCLI", "AEXML", "SwiftCodeGen"],
            path: "Interface/Sources/Generator",
            swiftSettings: [
                .define("GeneratingInterface"),
            ]),
        .target(
            name: "hyperdrive-cli",
            dependencies: ["Tokenizer", "Generator", "SwiftCodeGen"],
            path: "CLI/Sources/hyperdrive")
    ]
)
