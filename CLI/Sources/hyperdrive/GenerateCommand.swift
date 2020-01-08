//
//  GenerateCommand.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/02/2018.
//

#if canImport(Common)
import Common
#endif
import Generator
import Tokenizer
import Foundation
import XcodeProj
import SwiftCLI

import SwiftCodeGen


class GenerateCommand: Command {

    enum Output {
        case file(URL)
        case console
    }

    static let forbiddenNames = ["RootView", "UIView", "UIViewController", "self", "switch",
                                 "if", "else", "guard", "func", "class", "ViewBase", "ControllerBase", "for", "Component"]

    let name = "generate"
    let shortDescription = "Generate Swift UI code from XMLs"
    let liveConfigurations = VariadicKey<String>("--live-configurations", description: "Configurations to generate live UI code for. Environment variable $CONFIGURATION is used to determine current build configuration.")
    let livePlatforms = VariadicKey<String>("--live-platforms", description: "Platforms to generate live UI code for. Environment variable $PLATFORM_NAME is used to determine current build platform. Defaults to 'iphonesimulator'.")

    let xcodeProjectPath = Key<String>("--xcodeprojPath")
    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")
    let consoleOutput = Flag("--console-output")
    let applicationDescriptionFile = Key<String>("--description", description: "Path to an XML file with Application Description.")
    let swiftVersionParameter = Key<String>("--swift")
    let platform = Key<RuntimePlatform>("--platform") //, completion: .values(RuntimePlatform.allCases))
    let defaultAccessModifier = Key<String>("--defaultAccessModifier")
    let generateDisposableHelper = Flag("--generate-disposable-helper")
    // This means that a ReactantUI generator was already run with the same parameters, so we won't do some things like generate styles and themes
    let reactantUICompat = Flag("--x-compat")

    public func execute() throws {
        let output = DescriptionPipe()
        let livePlatforms = !self.livePlatforms.value.isEmpty ? self.livePlatforms.value : ["iphonesimulator"]
        let enableLive: Bool
        if let buildConfiguration = ProcessInfo.processInfo.environment["CONFIGURATION"],
            let buildPlatform = ProcessInfo.processInfo.environment["PLATFORM_NAME"] {

            enableLive = liveConfigurations.value.contains(buildConfiguration) && livePlatforms.contains(buildPlatform)
        } else {
            enableLive = false
        }

        guard let runtimePlatform = platform.value ?? ProcessInfo.processInfo.environment["PLATFORM_NAME"].flatMap(RuntimePlatform.from(platformName:)) else {
            throw GenerateCommandError.platformNotSpecified
        }

        guard let inputPath = inputPath.value else {
            throw GenerateCommandError.inputPathInvalid
        }
        let inputPathURL = URL(fileURLWithPath: inputPath)

        let outputType: Output
        if let outputFile = outputFile.value {
            outputType = .file(URL(fileURLWithPath: outputFile))
        } else if (consoleOutput.value) {
            outputType = .console
        } else {
            throw GenerateCommandError.ouputFileInvalid
        }

        let rawSwiftVersion = swiftVersionParameter.value ?? "4.1" // use 4.1 as default
        guard let swiftVersion = SwiftVersion(raw: rawSwiftVersion) else {
            throw GenerateCommandError.invalidSwiftVersion
        }

        let rawModifier = defaultAccessModifier.value ?? AccessModifier.internal.rawValue
        guard let accessModifier = AccessModifier(rawValue: rawModifier) else {
            throw GenerateCommandError.invalidAccessModifier
        }

        // ApplicationDescription is not required. We can work with default values and it makes it backward compatible.
        let applicationDescription: ApplicationDescription
        let applicationDescriptionPath = applicationDescriptionFile.value
        if let applicationDescriptionPath = applicationDescriptionPath {
            let applicationDescriptionData = try Data(contentsOf: URL(fileURLWithPath: applicationDescriptionPath))
            let xml = SWXMLHash.parse(applicationDescriptionData)
            if let node = xml["Application"].element {
                applicationDescription = try ApplicationDescription(node: node)
            } else {
                print("warning: ReactantUIGenerator: No <Application> element inside the application path!")
                return
                // FIXME: uncomment and delete the above when merged with `feature/logger` branch
//                Logger.instance.warning("Application file path does not contain the <Application> element.")
            }
        } else {
            applicationDescription = ApplicationDescription()
        }

        let minimumDeploymentTarget = try self.minimumDeploymentTarget()

        let uiXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let uiFiles = uiXmlEnumerator?.compactMap { $0 as? String }
            .filter {
                reactantUICompat.value ? $0.hasSuffix(".interface.xml") : $0.hasSuffix(".ui.xml")
            }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        let styleXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let styleFiles = styleXmlEnumerator?.compactMap { $0 as? String }.filter { $0.hasSuffix(".styles.xml") }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        let moduleRegistry = try ModuleRegistry(modules: [Module.mapKit, Module.uiKit, Module.webKit, Module.appKit], platform: runtimePlatform)

        let mainContext = MainDeserializationContext(
            elementFactories: moduleRegistry.factories,
            referenceFactoryProvider: moduleRegistry.referenceFactory(for:),
            platform: runtimePlatform)

        // path with the stylegroup associated with it
        var globalContextFiles = [] as [(path: String, group: StyleGroup)]
        var stylePaths = [] as [String]
        for path in styleFiles {
            output.line("// Generated from \(path)")
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)
            guard let element = xml["styleGroup"].element else { continue }
            let group: StyleGroup = try mainContext.deserialize(element: element)
            
            globalContextFiles.append((path, group))
            stylePaths.append(path)
        }

        let globalContext = GlobalContext(applicationDescription: applicationDescription,
                                          currentTheme: applicationDescription.defaultTheme,
                                          platform: runtimePlatform,
                                          styleSheets: globalContextFiles.map { $0.group })

        var componentTypes: [String] = []
        var imports: Set<String> = []
        for path in uiFiles {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)

            guard let node = xml.children.first?.element else { continue }
            var definition: ComponentDefinition
            do {
                let type = node.name
                if GenerateCommand.forbiddenNames.contains(type) {
                    throw GenerateCommandError.invalidType(path)
                }
                definition = try mainContext.deserialize(element: node, type: type)


            } catch let error {
                throw GenerateCommandError.tokenizationError(path: path, error: error)
            }
            componentTypes.append(contentsOf: definition.componentTypes)
            for definition in definition.componentDefinitions {
                globalContext.register(definition: definition, path: path)
            }
            imports.formUnion(definition.requiredImports)
            imports.formUnion(definition.styles.map { $0.parentModuleImport })
        }

        output.lines(
            runtimePlatform == .macOS ? "import AppKit" : "import UIKit",
            "import Hyperdrive",
            "import HyperdriveInterface",
            "import SnapKit"
        )

        if !reactantUICompat.value {
            for (offset: index, element: (path: path, group: group)) in globalContextFiles.enumerated() {
                let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                           localXmlPath: path,
                                                           isLiveEnabled: enableLive,
                                                           swiftVersion: swiftVersion,
                                                           defaultModifier: accessModifier)
                let styleContext = StyleGroupContext(globalContext: globalContext, group: group)
                output.append(try StyleGenerator(context: styleContext, configuration: configuration).generate(imports: index == 0))
            }
        }

        if !reactantUICompat.value {
            try output.append(theme(context: globalContext, swiftVersion: swiftVersion, platform: runtimePlatform))
        }

        if enableLive {
            output.append("import HyperdriveLiveInterface")
        }
        for imp in imports {
            output.append("import \(imp)")
        }

        let bundleTokenClass = Structure.class(accessibility: .private, name: "__HyperdriveUIBundleToken")
        let resourceBundeProperty = SwiftCodeGen.Property.constant(accessibility: .private, name: "__resourceBundle", value: .constant("Bundle(for: __HyperdriveUIBundleToken.self)"))

        output.append(bundleTokenClass)
        output.append(resourceBundeProperty)

        for (path, rootDefinition) in globalContext.componentDefinitions.definitionsByPath.sorted(by: { $0.key.compare($1.key) == .orderedAscending }) {
            output.append("// Generated from \(path)")
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive,
                                                       swiftVersion: swiftVersion,
                                                       defaultModifier: accessModifier)
            for definition in rootDefinition {
                let componentContext = ComponentContext(globalContext: globalContext, component: definition)
                output.append(try UIGenerator(componentContext: componentContext, configuration: configuration).generate(imports: false))
            }
        }

        if enableLive {
            let generatedApplicationDescriptionPath = applicationDescriptionPath.map { "\"\($0)\"" } ?? "nil"

            let configuration = Structure.struct(
                accessibility: .private,
                name: "GeneratedHyperdriveLiveUIConfiguration",
                inheritances: ["ReactantLiveUIConfiguration"],
                properties: [
                    .constant(name: "applicationDescriptionPath", type: "String?", value: .constant(generatedApplicationDescriptionPath)),
                    .constant(name: "rootDir", value: .constant(inputPath.enquoted)),
                    .constant(name: "resourceBundle", value: .constant("__resourceBundle")),
                    .constant(name: "commonStylePaths", type: "[String]", value: .arrayLiteral(items: stylePaths.map {
                        .constant($0.enquoted)
                    })),
                    .constant(
                        name: "componentTypes",
                        type: "[String: (HyperViewBase.Type, () -> HyperViewBase)]",
                        value: .dictionaryLiteral(items: Set(componentTypes).compactMap { componentType in
                            guard let definition = try? globalContext.definition(for: componentType), !definition.hasInjectedChildren else { return nil }
                            return (key: .constant(componentType.enquoted), value: .constant("(\(componentType).self, { \(componentType)() })"))
                        }))
                ])

            output.append(configuration)

            output.append("let bundleWorker = ReactantLiveUIWorker(configuration: GeneratedHyperdriveLiveUIConfiguration())")
        }

        let activateLiveReloadBlock: Block
        if enableLive {
            activateLiveReloadBlock = [
                .expression(.constant("ReactantLiveUIManager.shared.activate(in: window, worker: bundleWorker)")),
                .expression(.invoke(target: .constant("ApplicationTheme.selector.register"), arguments: [
                    MethodArgument(name: "target", value: .constant("bundleWorker")),
                    MethodArgument(name: "listener", value: .closure(Closure(parameters: ["theme"], block: [
                        .expression(.constant("bundleWorker.setSelectedTheme(name: theme.name)"))
                    ]))),
                ])),
            ]
        } else {
            activateLiveReloadBlock = []
        }

        let windowType = globalContext.platform == .macOS ? "NSWindow" : "UIWindow"
        let activateLiveReload = Function(
            accessibility: .public,
            name: "activateLiveInterface",
            parameters: [MethodParameter(label: "in", name: "window", type: windowType)],
            block: activateLiveReloadBlock)

        output.append(activateLiveReload)

        let result = output.result.joined(separator: "\n")

        switch outputType {
        case .console:
            print(result)
        case .file(let outputPathURL):
            try result.write(to: outputPathURL, atomically: true, encoding: .utf8)
        }
    }

    private func theme(context: GlobalContext, swiftVersion: SwiftVersion, platform: RuntimePlatform) throws -> Structure {
        let description = context.applicationDescription
        func allCases<T>(item: String, from container: ThemeContainer<T>) throws -> (isOptional: Bool, cases: [(Expression, Block)]) {
            let cases = try description.themes.map { theme -> (isOptional: Bool, expression: Expression, block: Block) in
                guard let themedItem = container[theme: theme, item: item] else {
                    throw GenerateCommandError.themedItemNotFound(theme: theme, item: item)
                }
                let typeContext = SupportedPropertyTypeContext(parentContext: context, value: .value(themedItem))
                let isOptional = themedItem.isOptional(context: typeContext)
                return (isOptional, Expression.constant(".\(theme)"), [.return(expression: themedItem.generate(context: typeContext))])
            }

            return (cases.contains { $0.isOptional }, cases.map { ($0.expression, $0.block) })
        }

        let themeProperty = SwiftCodeGen.Property.constant(accessibility: .fileprivate, name: "theme", type: "ApplicationTheme")

        func themeContainer<T>(from container: ThemeContainer<T>, named name: String) throws -> Structure {
            let themeProperty = SwiftCodeGen.Property.constant(accessibility: .fileprivate, name: "theme", type: "ApplicationTheme")

            let properties = try container.allItemNames.sorted().map { item -> SwiftCodeGen.Property in
                let (isOptional, cases) = try allCases(item: item, from: container)
                let switchStatement = Statement.switch(
                    expression: .constant("theme"),
                    cases: cases,
                    default: nil)

                return SwiftCodeGen.Property.variable(
                    accessibility: .public,
                    name: item,
                    type: T.typeFactory.runtimeType(for: platform).name + (isOptional ? "?" : ""),
                    block: [switchStatement])
            }

            return Structure.struct(
                accessibility: .public,
                name: name,
                properties: [themeProperty] + properties)
        }

        let colorsStruct = try themeContainer(from: description.colors, named: "Colors")

        let imagesStruct = try themeContainer(from: description.images, named: "Images")

        let fontsStruct = try themeContainer(from: description.fonts, named: "Fonts")

        let currentTheme = SwiftCodeGen.Property.variable(
            accessibility: .public,
            modifiers: .static,
            name: "current",
            type: "ApplicationTheme",
            block: [
                .return(expression: .constant("selector.currentTheme")),
            ])

        let selector = SwiftCodeGen.Property.constant(
            accessibility: .public,
            modifiers: .static,
            name: "selector",
            value: .constant("ReactantThemeSelector<ApplicationTheme>(defaultTheme: .\(description.defaultTheme))"))

        let colors = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "colors",
            type: "Colors",
            block: [
                .return(expression: .constant("Colors(theme: self)"))
            ])

        let images = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "images",
            type: "Images",
            block: [
                .return(expression: .constant("Images(theme: self)"))
            ])

        let fonts = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "fonts",
            type: "Fonts",
            block: [
                .return(expression: .constant("Fonts(theme: self)"))
            ])

        return Structure.enum(
            accessibility: .public,
            name: "ApplicationTheme",
            inheritances: ["String", "ReactantThemeDefinition"],
            containers: [colorsStruct, imagesStruct, fontsStruct],
            cases: description.themes.map {
                Structure.EnumCase(name: $0)
            },
            properties: [currentTheme, selector, colors, images, fonts])
    }

    private func minimumDeploymentTarget() throws -> Int {
        guard let xcodeProjectPathsString = xcodeProjectPath.value, let xcprojpath = URL(string: xcodeProjectPathsString) else {
            throw GenerateCommandError.XCodeProjectPathInvalid
        }

        let project: XcodeProj
        do {
            project = try XcodeProj(pathString: xcprojpath.absoluteURL.path)
        } catch {
            throw GenerateCommandError.cannotReadXCodeProj(error)
        }

        return project.pbxproj.buildConfigurations
            .compactMap { config -> Substring? in
                let value = (config.buildSettings["TVOS_DEPLOYMENT_TARGET"] ?? config.buildSettings["IPHONEOS_DEPLOYMENT_TARGET"]) as? String

                return value?.split(separator: ".").first
            }
            .compactMap { Int(String($0)) }.reduce(50) { previous, new in
                return previous < new ? previous : new
        }
    }

    private func ifSimulator(ifClause: Describable, elseClause: Describable? = nil) -> [Describable] {
        let elseCode: [Describable]
        if let elseClause = elseClause {
            elseCode = ["#else", elseClause]
        } else {
            elseCode = []
        }

        return ["#if targetEnvironment(simulator)", ifClause] +
            elseCode +
            ["#endif"]
    }
}
