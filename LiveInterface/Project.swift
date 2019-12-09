import ProjectDescription

enum HyperdrivePlatform: CaseIterable {
    case iOS
    case macOS
    case tvOS

    var name: String {
        switch self {
        case .iOS:
            return "iOS"
        case .macOS:
            return "macOS"
        case .tvOS:
            return "tvOS"
        }
    }

    var platform: Platform {
        switch self {
        case .iOS:
            return .iOS
        case .tvOS:
            return .tvOS
        case .macOS:
            return .macOS
        }
    }

    var deploymentTarget: DeploymentTarget? {
        switch self {
        case .iOS:
            return DeploymentTarget.iOS(targetVersion: "11.0", devices: [.iphone, .ipad, .mac])
        case .macOS:
            return DeploymentTarget.macOS(targetVersion: "10.13")
        case .tvOS:
            return nil
        }
    }
}

let targets = HyperdrivePlatform.allCases.map {
    Target(
        name: "HyperdriveLiveInterface-\($0.name)",
        platform: $0.platform,
        product: .framework,
        productName: "HyperdriveLiveInterface",
        bundleId: "org.brightify.hyperdrive.LiveInterface",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
            "Sources/Live/**",
            "../Interface/Sources/Common/**",
            "../Interface/Sources/Tokenizer/**",
        ],
        resources: [

        ],
        headers: Headers(
            project: [
                "Sources/Live/Utils/ExceptionCatcher/RUIExceptionCatcher.h",
            ]
        ),
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
            TargetDependency.project(target: "HyperdriveInterface-\($0.name)", path: "../Interface"),
        ],
        settings: Settings(base: [
            "OTHER_SWIFT_FLAGS": "$(inherited) -DHyperdriveRuntime",
            "SWIFT_OBJC_BRIDGING_HEADER": "Sources/Live/LiveInterface-Bridging-Header.h",
        ], defaultSettings: .recommended))
}

let playground = Target(
    name: "HyperdriveInterfacePlayground",
    platform: Platform.iOS,
    product: Product.app,
    productName: "HyperdriveInterfacePlayground",
    bundleId: "org.brightify.hyperdrive.InterfacePlayground",
    deploymentTarget: DeploymentTarget.iOS(targetVersion: "13.0", devices: [.iphone, .ipad, .mac]),
    infoPlist: "../Interface/Example/Metadata/Info.plist",
    sources: [
        "../Interface/Example/Source/**",
        "../Interface/Example/Generated/**",
    ],
    resources: [
        "../Interface/Example/Resource/**",
    ],
    actions: [
        TargetAction.pre(
            tool: "xcrun",
            arguments: [
                "swift", "run",
                "--package-path", "$SRCROOT/..",
                "hyperdrive", "generate",
                "--live-configurations", "Debug",
                "--live-platforms", "iphonesimulator",
                "--platform", "iOS",
                "--inputPath", "$SRCROOT/../Interface/Example/Source",
                "--outputFile", "$SRCROOT/../Interface/Example/Generated/GeneratedUI.swift",
                "--xcodeprojPath", "$SRCROOT/LiveInterface.xcodeproj",
                "--description", "$SRCROOT/../Interface/Example/Source/Example.hyperdrive.xml",
            ],
            name: "Generate Hyperdrive Interface",
            inputPaths: [],
            inputFileListPaths: [],
            outputPaths: [],
            outputFileListPaths: [])
    ],
    dependencies: [
        TargetDependency.target(name: "HyperdriveLiveInterface-iOS"),
        TargetDependency.project(target: "Hyperdrive-iOS", path: "../Platform")
    ])

let project = Project(
    name: "LiveInterface",
    targets: targets + [playground],
    additionalFiles: [
        "../HyperdriveLiveInterface.podspec",
        "../Interface/Example/Source/**/*.ui.xml",
        "../Interface/Example/Source/**/*.hyperdrive.xml",
        "../Interface/Example/Source/**/*.styles.xml",
    ])
