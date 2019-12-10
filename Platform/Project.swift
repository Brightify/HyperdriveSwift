import ProjectDescription
import Foundation

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
        name: "Hyperdrive-\($0.name)",
        platform: $0.platform,
        product: .framework,
        productName: "Hyperdrive",
        bundleId: "org.brightify.hyperdrive.Platform",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
            "Sources/**",
        ],
        resources: [
        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ],
        settings: Settings(base: [
            "OTHER_SWIFT_FLAGS": "$(inherited) -DEnableExperimentalFeatures",
        ], defaultSettings: .recommended))
}

let rxTargets = HyperdrivePlatform.allCases.map {
    Target(
        name: "RxHyperdrive-\($0.name)",
        platform: $0.platform,
        product: .framework,
        productName: "Hyperdrive",
        bundleId: "org.brightify.hyperdrive.Platform",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
            "Sources/**",
            "RxSources/**",
        ],
        resources: [
        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ]
    )
}

let testTargets = HyperdrivePlatform.allCases.map {
    Target(
        name: "HyperdriveTests-\($0.name)",
        platform: $0.platform,
        product: .unitTests,
        productName: "HyperdriveTests",
        bundleId: "org.brightify.hyperdrive.PlatformTests",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
           "Tests/CollectionView/**",
           "Tests/Configuration/**",
           "Tests/Core/**",
           "Tests/StaticMap/**",
           "Tests/StaticMap/**",
           "Tests/TableView/**",
           "Tests/TestUtils/**",
           "Tests/Validation/**",
           "Tests/Wireframe/**",
        ],
        resources: [
        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ])
}

let rxTestTargets = HyperdrivePlatform.allCases.map {
    Target(
        name: "RxHyperdriveTests-\($0.name)",
        platform: $0.platform,
        product: .unitTests,
        productName: "HyperdriveTests",
        bundleId: "org.brightify.hyperdrive.PlatformTests",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
           "Tests/**"
        ],
        resources: [
        ])
}

let schemes = HyperdrivePlatform.allCases.map {
    Scheme(
        name: "Hyperdrive-\($0.name)",
        shared: true,
        buildAction: BuildAction(targets: ["Hyperdrive-\($0.name)"]),
        testAction: TestAction(targets: ["HyperdriveTests-\($0.name)"]),
        runAction: nil)
}

let project = Project(
    name: "Platform",
    targets: targets + rxTargets + testTargets + rxTestTargets,
    schemes: schemes,
    additionalFiles: [
        "../HyperdrivePlatform.podspec"
    ])
