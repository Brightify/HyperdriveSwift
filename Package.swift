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
        .package(url: "https://github.com/tadija/AEXML.git", .exact("4.3.3")),
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.2.2")
    ],
    targets: [
        .target(
            name: "SwiftCodeGen",
            dependencies: [],
            path: "Interface/Sources/SwiftCodeGen"),
        .target(
            name: "Common",
            dependencies: [],
            path: "Interface/Sources/Common"),
        .target(
            name: "Tokenizer",
            dependencies: ["Common", "SwiftCodeGen"],
            path: "Interface/Sources/Tokenizer"),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "xcodeproj", "SwiftCLI", "AEXML", "SwiftCodeGen"],
            path: "Interface/Sources/Generator"),
        .target(
            name: "hyperdrive-cli",
            dependencies: ["Tokenizer", "Generator", "SwiftCodeGen"],
            path: "CLI/Sources/hyperdrive")
    ]
)
