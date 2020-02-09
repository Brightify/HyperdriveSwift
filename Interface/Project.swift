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
        name: "HyperdriveInterface-\($0.name)",
        platform: $0.platform,
        product: .framework,
        productName: "HyperdriveInterface",
        bundleId: "org.brightify.hyperdrive.Interface",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
            "Sources/Runtime/**",
            "Sources/Common/**",
        ],
        resources: [

        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ],
        settings: Settings(base: [
            "OTHER_SWIFT_FLAGS": "$(inherited) -DEnableHelperExtensions",
        ], defaultSettings: .recommended))
}

let testTargets = HyperdrivePlatform.allCases.map {
    Target(
        name: "HyperdriveInterfaceTests-\($0.name)",
        platform: $0.platform,
        product: .unitTests,
        productName: "HyperdriveInterfaceTests",
        bundleId: "org.brightify.hyperdrive.InterfaceTests",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info-Tests.plist",
        sources: [
           "Tests/**",
        ],
        resources: [
        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ])
}

let schemes = HyperdrivePlatform.allCases.map {
    Scheme(
        name: "HyperdriveInterface-\($0.name)",
        shared: true,
        buildAction: BuildAction(targets: [TargetReference(stringLiteral: "HyperdriveInterface-\($0.name)")]),
        testAction: TestAction(targets: [TestableTarget(stringLiteral: "HyperdriveInterfaceTests-\($0.name)")]),
        runAction: nil)
}

let project = Project(
    name: "Interface",
    targets: targets + testTargets,
    schemes: schemes,
    additionalFiles: [
        "../HyperdriveInterface.podspec",
    ])
