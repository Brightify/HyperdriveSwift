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
        ])
}

let project = Project(
    name: "Interface",
    targets: targets,
    additionalFiles: [
        "../HyperdriveInterface.podspec",
    ])
