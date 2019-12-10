//
//  GlobalContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation
#if canImport(HyperdriveInterface)
import HyperdriveInterface
#endif

/**
 * The topmost context (disregarding `ReactantLiveUIWorker.Context` which serves LiveUI purposes only).
 * Any data to be shared throughout the whole application (bundle) should be located in this context.
 */
public class GlobalContext: DataContext {
    private typealias StyleSheets = [String: [String: Style]]
    private typealias TemplateSheets = [String: [String: Template]]
    private typealias ComponentDefinitions = [String: ComponentDefinition]

    public var applicationDescription: ApplicationDescription
    public var currentTheme: ApplicationDescription.ThemeName
    public var resourceBundle: Bundle?
    public var platform: RuntimePlatform
    public private(set) var componentDefinitions = ComponentDefinitionDictionary()

    private var styles: StyleSheets = [:]
    private var templates: TemplateSheets = [:]

    public init() {
        self.applicationDescription = ApplicationDescription()
        self.currentTheme = applicationDescription.defaultTheme
        self.resourceBundle = Bundle.main
        self.platform = RuntimePlatform.current
    }

    public init(
        applicationDescription: ApplicationDescription,
        currentTheme: ApplicationDescription.ThemeName,
        resourceBundle: Bundle?,
        platform: RuntimePlatform,
        styleSheetDictionary: [String: StyleGroup])
    {
        self.applicationDescription = applicationDescription
        self.currentTheme = currentTheme
        self.resourceBundle = resourceBundle
        self.platform = platform

        setStyles(from: styleSheetDictionary)
    }

    public init(
        applicationDescription: ApplicationDescription,
        currentTheme: ApplicationDescription.ThemeName,
        platform: RuntimePlatform,
        styleSheets: [StyleGroup]) {
        self.applicationDescription = applicationDescription
        self.currentTheme = currentTheme
        self.platform = platform

        setStyles(from: styleSheets)
    }

    public func register(definition: ComponentDefinition, path: String) {
        componentDefinitions[path: path].append(definition)
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .global(let groupName, let name) = styleName else {
            fatalError("Global context cannot resolve local style name \(styleName.name).")
        }
        return "\(groupName.capitalizingFirstLetter())Styles.\(name)"
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .global(let groupName, let name) = styleName else { return nil }
        return styles[groupName]?[name]
    }

    public func template(named templateName: TemplateName) -> Template? {
        guard case .global(let groupName, let name) = templateName else { return nil }
        return templates[groupName]?[name]
    }

    public func themed(image name: String) -> Image? {
        return applicationDescription.images[theme: currentTheme, item: name].flatMap { $0 }
    }

    public func themed(color name: String) -> UIColorPropertyType? {
        return applicationDescription.colors[theme: currentTheme, item: name]
    }

    public func themed(font name: String) -> Font? {
        return applicationDescription.fonts[theme: currentTheme, item: name].flatMap { $0 }
    }

    public func setStyles(from styleSheetDictionary: [String: StyleGroup]) {
        styles = Dictionary(styleSheetDictionary.map { key, value in
            (key, Dictionary(value.styles.map { ($0.name.name, $0) }, uniquingKeysWith: { $1 }))
        }, uniquingKeysWith: { $1 })
    }

    public func setStyles(from styleSheets: [StyleGroup]) {
        let groups = Dictionary(grouping: styleSheets.flatMap { $0.styles }, by: { style -> String? in
            guard case .global(let groupName, _) = style.name else { return nil }
            return groupName
        })

        styles = Dictionary(groups.compactMap { name, styles -> (String, [String: Style])? in
            guard let name = name else { return nil }
            return (name, Dictionary(styles.map { ($0.name.name, $0) }, uniquingKeysWith: { $1 }))
        }, uniquingKeysWith: { $1 })
    }

    public func definition(for componentType: String) throws -> ComponentDefinition {
        guard let definition = componentDefinitions[type: componentType] else {
            throw TokenizationError(message: "Component \(componentType) not registered!")
        }

        return definition
    }

    public func resolveStyle(for element: UIElement, stateProperties: [Property], from styles: [Style]) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties + stateProperties }
        let viewStyles = try styles.compactMap { style -> Style? in
            if case .view(let styledType) = style.type, try styledType.runtimeType() == element.factory.runtimeType() {
                return style
            } else {
                return nil
            }
        }
        
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count + stateProperties.count)
        for name in element.styles {
            for property in try viewStyles.resolveViewStyle(for: element.factory.elementName, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties + stateProperties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    #if canImport(UIKit)
    public func resolveStateProperty(named: String) throws -> Any? {
        throw LiveUIError(message: "Couldn't resolve state named \(named). This should be caught sooner than in GlobalContext.")
    }
    #endif

}

private extension Sequence where Iterator.Element == Style {
    func resolveViewStyle(for type: String, named name: StyleName) throws -> [Property] {
        guard let style = first(where: { $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveViewStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}