//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

/**
 * The "file"'s context. This context is available throughout a Component's file.
 * It's used to resolve local styles and delegate global style resolving to global context.
 */
public class ComponentContext: DataContext {
    public let globalContext: GlobalContext
    public let component: ComponentDefinition

    public init(globalContext: GlobalContext, component: ComponentDefinition) {
        self.globalContext = globalContext
        self.component = component
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .local(let name) = styleName else {
            return globalContext.resolvedStyleName(named: styleName)
        }
        return component.stylesName + "Styles." + name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .local(let name) = styleName else {
            return globalContext.style(named: styleName)
        }
        return component.styles.first { $0.name.name == name }
    }

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

            public var factory: SupportedTypeFactory {
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

            public var defaultValue: AnySupportedType {
                #if canImport(SwiftCodeGen)
                return AnySupportedType(
                    factory: factory,
                    generateValue: { [item] context -> Expression in
                        .constant(item.defaultValue ?? #"#error("Default value not specified!")"#)
                    })
                #elseif canImport(UIKit)
                return AnySupportedType(
                    factory: factory,
                    resolveValue: { context in nil })
                #endif
            }
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

        let explicitStateItems = Dictionary(state.stateDescription.items.map { ($0.name, $0) }, uniquingKeysWith: { $1 })
            .mapValues(ResolvedStateItem.Description.init)

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
                firstApplication.property.typeFactory.runtimeType(for: .iOS) == application.property.typeFactory.runtimeType(for: .iOS)
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

    public func resolve(actions: [(element: UIElementBase, actions: [HyperViewAction])]) throws -> [ResolvedHyperViewAction] {
        let elementActions: [(element: UIElementBase, action: HyperViewAction, elementAction: UIElementAction)] = try actions.flatMap { element, actions in
            try actions.compactMap { action in
                guard let elementAction = try element.supportedActions(context: self).first(where: { $0.matches(action: action) }) else { return nil }
                return (element: element, action: action, elementAction: elementAction)
            }
        }

        #warning("Compute state once in init, not here for improved performance")
        let state = try resolve(state: component)

        let sourcesToVerify: [String: [ResolvedHyperViewAction.Source]] = try Dictionary(grouping: elementActions.map { element, action, elementAction in
            let parameters = try action.parameters.flatMap { label, parameter -> [ResolvedHyperViewAction.Parameter] in
                switch parameter {
                case .inheritedParameters:
                    return elementAction.parameters.enumerated().map { index, parameter in
                        let (label, type) = parameter
                        return ResolvedHyperViewAction.Parameter(label: label, kind: .local(name: label ?? "param\(index + 1)", type: type))
                    }
                case .constant(let type, let value):
                    guard let foundType = RuntimePlatform.iOS.supportedTypes.first(where: {
                        $0.runtimeType(for: .iOS).name == type && $0 is AttributeSupportedPropertyType.Type
                    }) as? AttributeSupportedPropertyType.Type else {
                        throw TokenizationError(message: "Unknown type \(type) for value \(value)")
                    }

                    let typedValue = try foundType.materialize(from: value)

                return [ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value: typedValue))]
//                    return ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value:     ))
                case .stateVariable(let name):
                    return [ResolvedHyperViewAction.Parameter(label: label, kind: .state(property: name, type: .propertyType(state[name]!.typeFactory)))]
                case .reference(var targetId, let propertyName):
                    let targetElement: UIElement
                    if targetId == "self" {
                        guard let foundTargetElement = element as? UIElement else {
                            throw TokenizationError(message: "Using `self` as target on non-UIElement is not yet supported!")
                        }
                        targetElement = foundTargetElement
                        targetId = targetElement.id.description
                    } else {
                        guard let foundTargetElement = component.allChildren.first(where: { $0.id.description == targetId }) else {
                            throw TokenizationError(message: "Element with id \(targetId) doesn't exist in \(component.type)!")
                        }
                        targetElement = foundTargetElement
                    }

                    if let propertyName = propertyName {
                        guard let property = targetElement.factory.availableProperties.first(where: { $0.name == propertyName }) else {
                            throw TokenizationError(message: "Element with id \(targetId) used in \(component.type) doesn't have property named \(propertyName).!")
                        }
                        return [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(view: targetId, property: propertyName, type: .propertyType(property.anyTypeFactory)))]
                    } else {
                        return try [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(view: targetId, property: nil, type: .elementReference(targetElement.runtimeType(for: .iOS))))]
                    }
                }
            }

            return ResolvedHyperViewAction.Source(actionName: action.name, element: element, action: elementAction, parameters: parameters)
        }, by: { $0.actionName })

        for (name, actions) in sourcesToVerify {
            guard let firstAction = actions.first else { continue }
            let verificationResult = actions.dropFirst().allSatisfy { action in
                guard action.parameters.count == firstAction.parameters.count else { return false }

                return action.parameters.enumerated().allSatisfy { index, parameter in
                    let firstActionParameter = firstAction.parameters[index]
                    return firstActionParameter.type == parameter.type
                }
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible actions found for name: \(name)!")
            }
        }

        return sourcesToVerify.map { name, sources in
            ResolvedHyperViewAction(name: name, parameters: sources.first!.parameters, sources: sources)
        }

//        return actionsToVerify.values.flatMap { $0 }

//        return [
//            ResolvedHyperViewAction(name: "a", parameters: [
//                ResolvedHyperViewAction.Parameter(label: "abc", kind: .constant(value: 100)),
//                ResolvedHyperViewAction.Parameter(label: "efg", kind: .reference(type: TransformedText.self))
//            ])
//        ]


//        action.parameters.map { label, parameter -> ResolvedHyperViewAction.Parameter in
//            switch parameter {
//            case .inheritedParameters:
//                break
//            case .constant(let type, let value):
//                break
//            case .stateVariable(let name):
//                break
//            case .reference(let targetId, let property):
//                break
//            }
//        }
    }

    /// Returns any state properties
    public func stateProperties(of element: UIElement) throws -> [Property] {
        #warning("FIXME This is extra hacky, it should be better to have a proper API for this")
        if let reference = element as? ComponentReference {
            let definition = try reference.definition ?? globalContext.definition(for: reference.type)
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
                    .constant(stateFactory.runtimeType(for: .iOS).name + "()")
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
                    _StateProperty(namespace: [PropertyContainer.Namespace(name: "state", isOptional: false)],
                                   name: name,
                                   anyDescription: _StateProperty.Description(name: name, namespace: [], anyDefaultValue: stateItem.defaultValue, anyTypeFactory: stateItem.typeFactory), anyValue: .state(name, factory: stateItem.typeFactory))
                }

            case .none:
                passthroughProperties = []
            }

            return try passthroughProperties + reference.possibleStateProperties.map { name, value -> Property in
                guard let stateProperty = state[name] else {
                    throw TokenizationError(message: "Element \(element) doesn't have a state property \(name)!")
                }

                let propertyValue: AnyPropertyValue
                if value.starts(with: "$") {
                    propertyValue = .state(String(value.dropFirst()), factory: stateProperty.typeFactory)
                } else if let attributeTypeFactory = stateProperty.typeFactory as? AttributeSupportedTypeFactory {
                    propertyValue = try .value(attributeTypeFactory.materialize(from: value))
                } else {
                    throw TokenizationError(message: "Property type \(stateProperty.typeFactory) not yet supported for state properties!")
                }

                return _StateProperty(namespace: [PropertyContainer.Namespace(name: "state", isOptional: false)], name: name, anyDescription:
                    _StateProperty.Description(name: name, namespace: [], anyDefaultValue: stateProperty.defaultValue, anyTypeFactory: stateProperty.typeFactory), anyValue: propertyValue)
            }
        } else {
            return []
        }
    }
    
    public func child(for definition: ComponentDefinition) -> ComponentContext {
        return ComponentContext(globalContext: globalContext, component: definition)
    }
}

extension ComponentContext: HasGlobalContext { }

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

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
