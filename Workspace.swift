import ProjectDescription

let workspace = Workspace(
    name: "Hyperdrive",
    projects: [
        "Platform",
        "Interface",
        "LiveInterface",
    ],
    additionalFiles: [
        "CLI/CLI.xcodeproj",
    ])
