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
#if canImport(SwiftCodeGen)
import SwiftCodeGen
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
            (key, Dictionary(value.styles.compactMap { try? Style(from: $0, context: self) }.map { ($0.name.name, $0) }, uniquingKeysWith: { $1 }))
        }, uniquingKeysWith: { $1 })
    }

    public func setStyles(from styleSheets: [StyleGroup]) {
        let groups = Dictionary(grouping: styleSheets.flatMap { $0.styles }, by: { style -> String? in
            guard case .global(let groupName, _) = style.name else { return nil }
            return groupName
        })

        styles = Dictionary(groups.compactMap { name, styles -> (String, [String: Style])? in
            guard let name = name else { return nil }
            return (name, Dictionary(styles.compactMap { try? Style(from: $0, context: self) }.map { ($0.name.name, $0) }, uniquingKeysWith: { $1 }))
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

extension GlobalContext {

    public struct ResolvedStateItem {
        public var name: String
        public var description: Description?
        public var typeFactory: SupportedTypeFactory
        public var defaultValue: SupportedPropertyType
        public var applications: [Application]

        public struct Application {
            public var element: UIElementBase
            public var property: StateProperty
        }

        public struct Description {
            public let item: ComponentDefinition.StateDescription.Item
            public let factory: SupportedTypeFactory
            public let defaultValue: SupportedPropertyType
        }
    }

    /// Returns all state properties of the element
    public func stateProperties(of element: UIElement) throws -> [Property] {
        #warning("FIXME This is extra hacky, it should be better to have a proper API for this")
        if let reference = element as? ComponentReference {
            let definition = try reference.definition ?? self.definition(for: reference.type)
            let state = try resolve(state: definition)

            let passthroughProperties: [Property]
            switch reference.passthroughState {
            case .property(let property)?:
                #if canImport(SwiftCodeGen)
                let stateFactory = AnySupportedTypeFactory(
                    xsdType: .builtin(.string),
                    resolveRuntimeType: { _ in
                        RuntimeType(name: definition.type + ".State")
                    },
                    generateStateAccess: { .constant($0) })
                #else
                let stateFactory = AnySupportedTypeFactory(
                    xsdType: .builtin(.string),
                    resolveRuntimeType: { _ in
                        RuntimeType(name: definition.type + ".State")
                    })
                #endif

                #if canImport(SwiftCodeGen)
                let defaultValue = AnySupportedType(factory: stateFactory) { context in
                    .constant(stateFactory.runtimeType(for: self.platform).name + "()")
                }
                #else
                let defaultValue = AnySupportedType(factory: stateFactory) { context in
                    fatalError("Not implemented")
                }
                #endif

                passthroughProperties = [_StatePassthroughProperty(
                    anyDescription: _StatePassthroughProperty.Description(anyDefaultValue: defaultValue, anyTypeFactory: stateFactory),
                    anyValue: .state(property, factory: stateFactory))]

            case .exported?:
                passthroughProperties = state.map { name, stateItem in
                    _StateProperty(namespace: [PropertyContainer.Namespace(name: "state", isOptional: false, swiftOnly: false)],
                                   name: name,
                                   anyDescription: _StateProperty.Description(name: name, namespace: [], anyDefaultValue: stateItem.defaultValue, anyTypeFactory: stateItem.typeFactory), anyValue: .state(name, factory: stateItem.typeFactory))
                }

            case .none:
                passthroughProperties = []
            }

            let elementName: String
            switch element.id {
            case .provided(let id):
                elementName = "\(id): \(reference.type)"
            case .generated:
                elementName = reference.type
            }

            return try stateProperties(
                elementName: elementName,
                state: state,
                possibleStateProperties: reference.possibleStateProperties,
                passthroughProperties: passthroughProperties)
        } else {
            return []
        }
    }

    public func stateProperties(for style: Style, factory: UIElementFactory) throws -> [Property] {
        guard let definition = try? self.definition(for: factory.elementName) else { return [] }
        let state = try resolve(state: definition)

        return try stateProperties(
            elementName: factory.elementName,
            state: state,
            possibleStateProperties: style.possibleStateProperties)
        
    }

    private func stateProperties(
        elementName: String,
        state: [String: ResolvedStateItem],
        possibleStateProperties: [String: String],
        passthroughProperties: [Property] = []
    ) throws -> [Property] {
        return try passthroughProperties + possibleStateProperties.map { name, value -> Property in
            guard let stateProperty = state[name] else {
                throw TokenizationError(message: "Element \(elementName) doesn't have a state property \(name)!")
            }

            let propertyValue: AnyPropertyValue
            if value.starts(with: "$") {
                propertyValue = .state(String(value.dropFirst()), factory: stateProperty.typeFactory)
            } else if let attributeTypeFactory = stateProperty.typeFactory as? AttributeSupportedTypeFactory {
                propertyValue = try .value(attributeTypeFactory.materialize(from: value))
            } else {
                propertyValue = .raw(.constant(value), requiresTheme: false)
            }

            return _StateProperty(namespace: [PropertyContainer.Namespace(name: "state", isOptional: false, swiftOnly: false)], name: name, anyDescription:
                _StateProperty.Description(name: name, namespace: [], anyDefaultValue: stateProperty.defaultValue, anyTypeFactory: stateProperty.typeFactory), anyValue: propertyValue)
        }
    }

    public func resolve(state: ComponentDefinition) throws -> [String: ResolvedStateItem] {
        let extraStateProperties = try state.allChildren.map { child -> (element: UIElementBase, properties: [StateProperty]) in
            let props = try self.stateProperties(of: child).compactMap { property -> StateProperty? in
                guard case .state(let name, let typeFactory) = property.anyValue else { return nil }
                return StateProperty(name: name, typeFactory: typeFactory, property: property)
            }
            return (element: child, properties: props)
        }
        let stateProperties = (state.allStateProperties + extraStateProperties).flatMap { element, properties in
            properties.map { (element: element, property: $0) }
        }

        let explicitStateItems = try Dictionary(state.stateDescription.items.map { ($0.name, $0) }, uniquingKeysWith: { $1 })
            .mapValues(resolveDescription(item:))

        var applicationsToVerify: [String: [ResolvedStateItem.Application]] = Dictionary(grouping: stateProperties.map { element, property in
            ResolvedStateItem.Application(element: element, property: property)
        }, by: { String($0.property.name.prefix(while: { $0 != "." })) })

        for name in explicitStateItems.keys {
            if !applicationsToVerify.keys.contains(name) {
                applicationsToVerify[name] = []
            }
        }

        for (name, applications) in applicationsToVerify {
            // We don't verify explicitly described state items
            if explicitStateItems[name] != nil {
                continue
            }

            guard let firstApplication = applications.first else { continue }
            let verificationResult = applications.dropFirst().allSatisfy { application in
                firstApplication.property.typeFactory.runtimeType(for: platform) == application.property.typeFactory.runtimeType(for: platform)
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible state item found for name: \(name)!")
            }
        }

        return Dictionary(uniqueKeysWithValues: applicationsToVerify.map { name, applications in
            let factory: SupportedTypeFactory
            let defaultValue: SupportedPropertyType
            if let description = explicitStateItems[name] {
                factory = description.factory
                defaultValue = description.defaultValue
            } else {
                let firstApplication = applications.first!
                factory = firstApplication.property.typeFactory
                defaultValue = firstApplication.property.property.anyDescription.anyDefaultValue
            }

            return (name, ResolvedStateItem(
                name: name,
                description: explicitStateItems[name],
                typeFactory: factory,
                defaultValue: defaultValue,
                applications: applications))
        })
    }

    private func resolveDescription(item: ComponentDefinition.StateDescription.Item) throws -> ResolvedStateItem.Description {
        let detectedTypeFactory = detectAttributeTypeFactory(from: item.type)
        let detectedDefaultValue = try item.defaultValue.flatMap { try detectedTypeFactory?.materialize(from: $0) }

        var fallbackFactory: SupportedTypeFactory {
            #if canImport(SwiftCodeGen)
            return AnySupportedTypeFactory(
                isNullable: item.isOptional,
                xsdType: .builtin(.string),
                resolveRuntimeType: { [item] _ in RuntimeType(name: item.type) },
                generateStateAccess: { .constant($0) })
            #else
            return AnySupportedTypeFactory(
                isNullable: item.isOptional,
                xsdType: .builtin(.string),
                resolveRuntimeType: { [item] _ in RuntimeType(name: item.type) })
            #endif
        }

        var fallbackDefaultValue: AnySupportedType {
            #if canImport(SwiftCodeGen)
            return AnySupportedType(
                factory: fallbackFactory,
                generateValue: { [item] context -> Expression in
                    .constant(item.defaultValue ?? #"#error("Default value not specified!")"#)
                })
            #elseif canImport(UIKit)
            return AnySupportedType(
                factory: factory,
                resolveValue: { context in nil })
            #endif
        }

        return ResolvedStateItem.Description(
            item: item,
            factory: detectedTypeFactory ?? fallbackFactory,
            defaultValue: detectedDefaultValue ?? fallbackDefaultValue)
    }

    private func detectAttributeTypeFactory(from name: String) -> AttributeSupportedTypeFactory? {
        if name.hasSuffix("?") {
            return detectAttributeTypeFactory(from: String(name.dropLast()))
                .map {
                    WrappingAttributeSupportedType.WrappingAttributeFactory(wrapping: $0, wrapKind: .optional)
                }
        } else if name.hasPrefix("[") && name.hasSuffix("]") {
            return detectAttributeTypeFactory(from: String(name.dropFirst().dropLast()))
                .map {
                    WrappingAttributeSupportedType.WrappingAttributeFactory(wrapping: $0, wrapKind: .array)
                }
        } else {
            return platform.supportedTypes.first(where: { factory in
                factory.runtimeType(for: platform).name == name && factory is AttributeSupportedTypeFactory
            }) as? AttributeSupportedTypeFactory
        }
    }
}


private struct _StatePassthroughProperty: Property {
    struct Description: PropertyDescription {
        var name: String = "state"
        var namespace: [PropertyContainer.Namespace] = []
        var anyDefaultValue: SupportedPropertyType
        var anyTypeFactory: SupportedTypeFactory

        init(anyDefaultValue: SupportedPropertyType, anyTypeFactory: SupportedTypeFactory) {
            self.anyDefaultValue = anyDefaultValue
            self.anyTypeFactory = anyTypeFactory
        }
    }

    var namespace: [PropertyContainer.Namespace] = []
    var name: String = "state"
    let anyDescription: PropertyDescription
    var anyValue: AnyPropertyValue

    var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    init(anyDescription: PropertyDescription, anyValue: AnyPropertyValue) {
        self.anyDescription = anyDescription
        self.anyValue = anyValue
    }

    #if canImport(SwiftCodeGen)
    public func application(context: PropertyContext) -> Expression {
        return anyValue.generate(context: context.child(for: anyValue))
    }

    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)

        return .expression(.invoke(
            target: .member(target: .member(target: .constant(namespacedTarget), name: name), name: "apply"),
            arguments: [
                MethodArgument(name: "from", value: application(context: context))
            ])
        )
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize(context: context.child(for: value)))
    }
    #endif

    #if canImport(UIKit)
    public func apply(on object: AnyObject, context: PropertyContext) throws {
        guard let target = object as? LiveHyperViewBase else {
            throw LiveUIError(message: "_StateProperty application is available only on instances of `LiveHyperViewBase`. Used \(object)!")
        }

        try target.stateProperty(named: name)?.set(value: anyValue.runtimeValue(context: context.child(for: anyValue)))
    }
    #endif
}


#if canImport(UIKit)
import UIKit
#endif

private struct _StateProperty: Property {
    struct Description: PropertyDescription {
        var name: String
        var namespace: [PropertyContainer.Namespace]
        var anyDefaultValue: SupportedPropertyType
        var anyTypeFactory: SupportedTypeFactory
    }

    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public let anyDescription: PropertyDescription
    public var anyValue: AnyPropertyValue

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    #if canImport(SwiftCodeGen)
    /**
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(context: PropertyContext) -> Expression {
        return anyValue.generate(context: context.child(for: anyValue))
    }

    /**
     * - parameter target: UI element to be targetted with the property
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)

        return .assignment(target: .member(target: .constant(namespacedTarget), name: name), expression: application(context: context))
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize(context: context.child(for: value)))
    }
    #endif

    #if canImport(UIKit)
    /**
     * Try to apply the property on an object using the passed property context.
     * - parameter object: UI element to apply the property to
     * - parameter context: property context to use
     */
    public func apply(on object: AnyObject, context: PropertyContext) throws {
        guard let target = object as? LiveHyperViewBase else {
            throw LiveUIError(message: "_StateProperty application is available only on instances of `LiveHyperViewBase`. Used \(object)!")
        }

        try target.stateProperty(named: name)?.set(value: anyValue.runtimeValue(context: context.child(for: anyValue)))
    }
    #endif
}

private final class WrappingAttributeSupportedType: AttributeSupportedPropertyType {
    enum ValueKind {
        case optional(Optional<AttributeSupportedPropertyType>)
        case array([AttributeSupportedPropertyType])
    }

    final class WrappingAttributeFactory: AttributeSupportedTypeFactory {
        enum Kind {
            case optional
            case array
        }

        public var xsdType: XSDType {
            return wrapping.xsdType
        }

        public var isNullable: Bool {
            switch wrapKind {
            case .optional:
                return true
            case .array:
                return false
            }
        }

        private let wrapping: AttributeSupportedTypeFactory
        private let wrapKind: Kind

        public init(wrapping: AttributeSupportedTypeFactory, wrapKind: Kind) {
            self.wrapping = wrapping
            self.wrapKind = wrapKind
        }

        func materialize(from value: String) throws -> AttributeSupportedPropertyType {
            switch wrapKind {
            case .array:
                // See Array.swift for documentation
                let values = try value.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
                    .map { try wrapping.materialize(from: $0) }
                return WrappingAttributeSupportedType(factory: self, value: .array(values))

            case .optional:
                return WrappingAttributeSupportedType(factory: self, value: .optional(value == "" ? nil : try wrapping.materialize(from: value)))

            }
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            let wrappedRuntimeType = wrapping.runtimeType(for: platform)

            let name: String
            switch wrapKind {
            case .optional:
                name = "\(wrappedRuntimeType.name)?"
            case .array:
                name = "[\(wrappedRuntimeType.name)]"
            }

            return RuntimeType(name: name, modules: wrappedRuntimeType.modules)
        }
    }

    static func materialize(from value: String) throws -> Self {
        fatalError("Not supported!")
    }

    var factory: SupportedTypeFactory
    var value: ValueKind

    var requiresTheme: Bool {
        switch value {
        case .array(let array):
            return array.contains { $0.requiresTheme }
        case .optional(let value):
            return value?.requiresTheme ?? false
        }
    }

    init(factory: WrappingAttributeFactory, value: ValueKind) {
        self.factory = factory
        self.value = value
    }

    #if canImport(SwiftCodeGen)
    func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch value {
        case .array(let values):
            return Expression.arrayLiteral(items: values.map { $0.generate(context: context) })

        case .optional(let value):
            return value?.generate(context: context) ?? Expression.constant("nil")
        }
    }
    #endif
}
