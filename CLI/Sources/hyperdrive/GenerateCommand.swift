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

protocol GeneratorOutput {
    func insert<S: Sequence>(commonImports: S) where S.Element == String

    func insert<S: Sequence>(imports: S, sourceFilePath: String) where S.Element == String

    func append(common: Describable)

    func append(_ describable: Describable, sourceFilePath: String)

    func flush() throws
}

final class ConsoleGeneratorOutput: GeneratorOutput {
    private let descriptionPipe = DescriptionPipe()
    private var imports: Set<String> = []

    init() {
    }

    func insert<S: Sequence>(commonImports: S) where S.Element == String {
        self.imports.formUnion(commonImports)
    }

    func insert<S: Sequence>(imports: S, sourceFilePath: String) where S.Element == String {
        self.imports.formUnion(imports)
    }

    func append(common describable: Describable) {
        descriptionPipe.append(describable)
    }

    func append(_ describable: Describable, sourceFilePath: String) {
        descriptionPipe.line("// Generated from \(sourceFilePath)")
        descriptionPipe.append(describable)
    }

    func flush() {
        let importsHeader = imports.sorted().map { "import \($0)" }
        let result = (importsHeader + descriptionPipe.result).joined(separator: "\n")
        print(result)
    }
}

final class SingleFileGeneratorOutput: GeneratorOutput {
    private let descriptionPipe = DescriptionPipe()
    private let outputFile: URL
    private var imports: Set<String> = []

    init(outputFile: URL) {
        self.outputFile = outputFile
    }

    func insert<S: Sequence>(commonImports: S) where S.Element == String {
        self.imports.formUnion(commonImports)
    }

    func insert<S: Sequence>(imports: S, sourceFilePath: String) where S.Element == String {
        self.imports.formUnion(imports)
    }

    func append(common describable: Describable) {
        descriptionPipe.append(describable)
    }

    func append(_ describable: Describable, sourceFilePath: String) {
        descriptionPipe.line("// Generated from \(sourceFilePath)")
        descriptionPipe.append(describable)
    }

    func flush() throws {
        let importsHeader = imports.sorted().map { "import \($0)" }
        let result = (importsHeader + descriptionPipe.result).joined(separator: "\n")
        try result.write(to: outputFile, atomically: true, encoding: .utf8)
    }
}

final class DirectoryGeneratorOutput: GeneratorOutput {
    private let outputPath: URL
    private var commonImports: Set<String> = []
    private var commonDescriptionPipe = DescriptionPipe()
    private var fileImports: [String: Set<String>] = [:]
    private var fileDescriptionPipes: [String: DescriptionPipe] = [:]

    init(outputPath: URL) {
        self.outputPath = outputPath
    }

    func insert<S: Sequence>(commonImports: S) where S.Element == String {
        self.commonImports.formUnion(commonImports)
    }

    func insert<S: Sequence>(imports: S, sourceFilePath: String) where S.Element == String {
        self.fileImports[sourceFilePath, default: []].formUnion(imports)
    }

    func append(common describable: Describable) {
        commonDescriptionPipe.append(describable)
    }

    func append(_ describable: Describable, sourceFilePath: String) {
        let filePipe: DescriptionPipe
        if let pipe = fileDescriptionPipes[sourceFilePath] {
            filePipe = pipe
        } else {
            filePipe = DescriptionPipe()
            fileDescriptionPipes[sourceFilePath] = filePipe
        }

        filePipe.append(describable)
    }

    func flush() throws {
        let commonImportsHeader = commonImports.sorted().map { "import \($0)" }
        let commonResult = commonDescriptionPipe.result

        for (path, pipe) in fileDescriptionPipes {
            let url = URL(fileURLWithPath: path)
            let fileName = url.deletingPathExtension().lastPathComponent
            let outputFile = outputPath.appendingPathComponent("\(fileName).generated.swift")
            guard compare(sourcePath: path, updatedSince: outputFile.path) else { continue }

            let fileImports = self.fileImports[path, default: []].sorted().map { "import \($0)" }
            let header = ["// Generated from \(path)"]
            let result = (header + commonImportsHeader + fileImports + pipe.result + commonResult).joined(separator: "\n")

            try result.write(to: outputFile, atomically: true, encoding: .utf8)
        }
    }

    private func compare(sourcePath: String, updatedSince targetPath: String) -> Bool {
        let fileManager = FileManager.default
        do {
            let sourceAttributes = try fileManager.attributesOfItem(atPath: sourcePath)
            let targetAttributes = try fileManager.attributesOfItem(atPath: targetPath)

            let sourceModificationDate = sourceAttributes[.modificationDate] as? Date ?? Date.distantFuture
            let targetModificationDate = targetAttributes[.modificationDate] as? Date ?? Date.distantPast

            // If source modification date is greater than target modification date, that means source is further along in the future
            return sourceModificationDate.compare(targetModificationDate) == .orderedDescending
        } catch {
            // If we can't get the information, let's make sure we generate the target file
            return true
        }
    }
}

class GenerateCommand: Command {
    static let forbiddenNames = ["RootView", "UIView", "UIViewController", "self", "switch",
                                 "if", "else", "guard", "func", "class", "ViewBase", "ControllerBase", "for", "Component"]

    let name = "generate"
    let shortDescription = "Generate Swift UI code from XMLs"
    let liveConfigurations = VariadicKey<String>("--live-configurations", description: "Configurations to generate live UI code for. Environment variable $CONFIGURATION is used to determine current build configuration.")
    let livePlatforms = VariadicKey<String>("--live-platforms", description: "Platforms to generate live UI code for. Environment variable $PLATFORM_NAME is used to determine current build platform. Defaults to 'iphonesimulator'.")

    let xcodeProjectPath = Key<String>("--xcodeprojPath")
    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")
    let outputPath = Key<String>("--outputPath")
    let consoleOutput = Flag("--console-output")
    let applicationDescriptionFile = Key<String>("--description", description: "Path to an XML file with Application Description.")
    let swiftVersionParameter = Key<String>("--swift")
    let platform = Key<RuntimePlatform>("--platform") //, completion: .values(RuntimePlatform.allCases))
    let defaultAccessModifier = Key<String>("--defaultAccessModifier")
    let generateDisposableHelper = Flag("--generate-disposable-helper")
    // This means that a ReactantUI generator was already run with the same parameters, so we won't do some things like generate styles and themes
    let reactantUICompat = Flag("--x-compat")

    public func execute() throws {
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

        let output: GeneratorOutput
        if let outputPath = outputPath.value {
            output = DirectoryGeneratorOutput(outputPath: URL(fileURLWithPath: outputPath))
        } else if let outputFile = outputFile.value {
            output = SingleFileGeneratorOutput(outputFile: URL(fileURLWithPath: outputFile))
        } else if (consoleOutput.value) {
            output = ConsoleGeneratorOutput()
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

        func loadDescription(from descriptionPath: String) throws -> ApplicationDescription {
            let applicationDescriptionData = try Data(contentsOf: URL(fileURLWithPath: descriptionPath))
            let xml = SWXMLHash.parse(applicationDescriptionData)
            if let node = xml["Application"].element {
                return try ApplicationDescription(node: node, parentFactory: loadDescription(from:))
            } else {
                print("warning: ReactantUIGenerator: No <Application> element inside the application path!")
                #warning("FIXME: uncomment and delete the above when merged with `feature/logger` branch")
//                Logger.instance.warning("Application file path does not contain the <Application> element.")
                throw GenerateCommandError.applicationDescriptionFileInvalid
            }
        }

        // ApplicationDescription is not required. We can work with default values and it makes it backward compatible.
        let applicationDescription: ApplicationDescription
        let applicationDescriptionPath: String
        if let descriptionPath = applicationDescriptionFile.value {
            applicationDescriptionPath = descriptionPath
            applicationDescription = try loadDescription(from: descriptionPath)
        } else {
            throw GenerateCommandError.applicationDescriptionFileInvalid
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

        output.insert(commonImports: [
            runtimePlatform == .macOS ? "AppKit" : "UIKit",
            "Hyperdrive",
            "HyperdriveInterface",
            "SnapKit",
        ])

        if !reactantUICompat.value {
            for (offset: index, element: (path: path, group: group)) in globalContextFiles.enumerated() {
                let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                           localXmlPath: path,
                                                           isLiveEnabled: enableLive,
                                                           swiftVersion: swiftVersion,
                                                           defaultModifier: accessModifier)
                let styleContext = StyleGroupContext(globalContext: globalContext, group: group)
                output.append(try StyleGenerator(context: styleContext, configuration: configuration).generate(imports: index == 0), sourceFilePath: path)
            }
        }

        if !reactantUICompat.value {
            try output.append(theme(context: globalContext, swiftVersion: swiftVersion, platform: runtimePlatform), sourceFilePath: applicationDescriptionPath)
        }

        if enableLive {
            output.insert(commonImports: ["HyperdriveLiveInterface"])
        }
        #warning("FIXME: Register each import per file to reduce unused imports")
        output.insert(commonImports: imports)

        let bundleTokenClass = Structure.class(accessibility: .private, name: "__HyperdriveUIBundleToken")
        let resourceBundleProperty = SwiftCodeGen.Property.constant(accessibility: .private, name: "__resourceBundle", value: .constant("Bundle(for: __HyperdriveUIBundleToken.self)"))
        let translateFunction = Function(
            accessibility: .private,
            name: "__translate",
            parameters: [
                MethodParameter(name: "key", type: "String"),
            ],
            returnType: "String",
            block: [
                .return(expression:
                    .invoke(target: .constant("NSLocalizedString"), arguments: [
                        MethodArgument(value: .constant("key")),
                        MethodArgument(name: "tableName", value: .constant(applicationDescription.defaultLocalizationsTable?.enquoted ?? "nil")),
                        MethodArgument(name: "bundle", value: .constant("__resourceBundle")),
                        MethodArgument(name: "comment", value: .constant("".enquoted)),
                    ]))
            ])

        output.append(common: bundleTokenClass)
        output.append(common: resourceBundleProperty)
        output.append(common: translateFunction)

        for (path, rootDefinition) in globalContext.componentDefinitions.definitionsByPath.sorted(by: { $0.key.compare($1.key) == .orderedAscending }) {
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive,
                                                       swiftVersion: swiftVersion,
                                                       defaultModifier: accessModifier)
            for definition in rootDefinition {
                let componentContext = ComponentContext(globalContext: globalContext, component: definition)
                output.append(try UIGenerator(componentContext: componentContext, configuration: configuration).generate(imports: false), sourceFilePath: path)
            }
        }

        if enableLive {
            let configuration = Structure.struct(
                accessibility: .private,
                name: "GeneratedHyperdriveLiveUIConfiguration",
                inheritances: ["ReactantLiveUIConfiguration"],
                properties: [
                    .constant(name: "applicationDescriptionPath", type: "String?", value: .constant(applicationDescriptionPath)),
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

            output.append(configuration, sourceFilePath: applicationDescriptionPath)

            output.append("let bundleWorker = ReactantLiveUIWorker(configuration: GeneratedHyperdriveLiveUIConfiguration())", sourceFilePath: applicationDescriptionPath)
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

        output.append(activateLiveReload, sourceFilePath: applicationDescriptionPath)

        try output.flush()
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
