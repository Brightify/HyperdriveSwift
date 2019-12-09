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
        name: "Hyperdrive-\($0.name)",
        platform: $0.platform,
        product: .framework,
        productName: "Hyperdrive",
        bundleId: "org.brightify.hyperdrive.Platform",
        deploymentTarget: $0.deploymentTarget,
        infoPlist: "Metadata/Info.plist",
        sources: [
            "Sources/Core/**",
            "Sources/Utils/**",
            "Sources/Validation/**",
        ],
        resources: [
        ],
        dependencies: [
            TargetDependency.cocoapods(path: ".."),
        ])
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
            "Sources/ActivityIndicator/**",
            "Sources/Core/**",
            "Sources/Core+RxSwift/**",
            "Sources/Utils/**",
            "Sources/Utils+RxSwift/**",
            "Sources/Validation/**",
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

let schemes = [
    Scheme(
        name: "Hyperdrive-iOS",
        shared: false,
        buildAction: BuildAction(targets: ["Hyperdrive-iOS"]),
        testAction: TestAction(targets: ["HyperdriveTests-iOS"]),
        runAction: nil)
]

let project = Project(
    name: "Platform",
    targets: targets + rxTargets + testTargets + rxTestTargets,
    schemes: schemes,
    additionalFiles: [
        "../HyperdrivePlatform.podspec"
    ])

//Project(name: , packages: [Package], settings: , targets:, schemes: , additionalFiles: )
