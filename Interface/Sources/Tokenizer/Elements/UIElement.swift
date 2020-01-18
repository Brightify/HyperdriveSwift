//
//  UIElement.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

public struct ResolvedHyperViewAction {
    public var name: String
    public var parameters: [Parameter]
    public var sources: [Source]

    #if canImport(SwiftCodeGen)
    public func observeSources(context: ComponentContext, actionPublisher: Expression) throws -> Block {
        var block = Block()

        let actionCase = Expression.constant(".\(name)")

        for source in sources {
            let actionArguments = parameters.map { parameter -> MethodArgument in
                switch parameter.kind {
                case .constant(let value):
                    let context = SupportedPropertyTypeContext(parentContext: context, value: .value(value))
                    return MethodArgument(name: parameter.label, value: value.generate(context: context))
                case .local(let name, _):
                    return MethodArgument(name: parameter.label, value: .constant(name))
                case .reference(let view, let property?, _):
                    return MethodArgument(name: parameter.label, value: .member(target: .constant(view), name: property))
                case .reference(let view, nil, _):
                    return MethodArgument(name: parameter.label, value: .constant(view))
                case .state(let property, _):
                    return MethodArgument(name: parameter.label, value: .member(target: .constant("state"), name: property))
                }
            }

            let handler = UIElementActionObservationHandler(
                publisher: .expression(.invoke(target: .member(target: actionPublisher, name: "publish"), arguments: [
                    MethodArgument(name: "action", value: actionArguments.isEmpty ? actionCase : .invoke(target: actionCase, arguments: actionArguments))
                ])),
                captures: parameters.compactMap { parameter in
                    switch parameter.kind {
                    case .constant, .local:
                        return nil
                    case .reference(let view, _, _):
                        return .unowned(.constant(view))
                    case .state:
                        return .strong(.constant("state"))
                    }
                },
                innerParameters: source.action.parameters.enumerated().map { index, parameter in
                    parameter.label ?? "param\(index + 1)"
                })

            if let element = source.element as? UIElement {
                block += try source.action.observe(on: .constant(element.id.description), handler: handler)
            } else {
                #warning("FIXME: We shouldn't assume that nonconformity to UIElement means it's the parent component!")
                block += try source.action.observe(on: .constant("self"), handler: handler)
            }
        }

        return block
    }
    #endif

    public struct Source {
        public var actionName: String
        public var element: UIElementBase
        public var action: UIElementAction
        public var parameters: [Parameter]
    }

    public struct Parameter {
        public var label: String?
        public var kind: Kind
        public var type: SupportedActionType {
            switch kind {
            case .local(_, let type), .reference(_, _, let type), .state(_, let type):
                return type
            case .constant(let value):
                return .propertyType(value.factory)
            }
        }

        public enum Kind {
            case local(name: String, type: SupportedActionType)
            case reference(view: String, property: String?, type: SupportedActionType)
            case state(property: String, type: SupportedActionType)
            case constant(value: SupportedPropertyType)
        }
    }
}

public enum SupportedActionType: Equatable {
    case propertyType(SupportedTypeFactory)
    case componentAction(component: String)
    case elementReference(RuntimeType)

    public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        switch self {
        case .propertyType(let type):
            return type.runtimeType(for: platform)
        case .componentAction(let component):
            return RuntimeType(name: "\(component).Action")
        case .elementReference(let type):
            return type
        }
    }

    public static func ==(lhs: SupportedActionType, rhs: SupportedActionType) -> Bool {
        switch (lhs, rhs) {
        case (.propertyType(let lhs), .propertyType(let rhs)):
            return RuntimePlatform.allCases.allSatisfy { lhs.runtimeType(for: $0) == rhs.runtimeType(for: $0) }
        case (.componentAction(let lhs), .componentAction(let rhs)):
            return lhs == rhs
        case (.elementReference(let lhs), .elementReference(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

public struct HyperViewAction {
    public var name: String
    public var eventName: String
    public var parameters: [(label: String?, parameter: Parameter)]

    public enum Parameter {
        case inheritedParameters
        case constant(type: String, value: String)
        case stateVariable(name: String)
        case reference(targetId: String, property: String?)
    }

    public init(name: String, eventName: String, parameters: [(label: String?, parameter: Parameter)]) {
        self.name = name
        self.eventName = eventName
        self.parameters = parameters
    }

    public init?(attribute: XMLAttribute) throws {
        let prefix = "action:"
        guard attribute.name.starts(with: prefix) else { return nil }

        eventName = String(attribute.name.dropFirst(prefix.count))

        self = try ActionParser(tokens: Lexer.tokenize(input: attribute.text)).parseAction(eventName: eventName)

        if parameters.isEmpty {
            parameters.append((label: nil, parameter: .inheritedParameters))
        }
    }
}

#if canImport(SwiftCodeGen)
public struct UIElementActionObservationHandler {
    let publisher: Statement
    let innerParameters: [String]
    let captures: [Closure.Capture]

    var listener: Closure {
        return Closure(
            captures: captures,
            parameters: innerParameters,
            block: [
                publisher,
            ])
    }

    init(publisher: Statement, captures: [Closure.Capture], innerParameters: [String]) {
        self.publisher = publisher
        self.captures = captures
        self.innerParameters = innerParameters
    }
}
#endif

public protocol UIElementAction {
    typealias Parameter = (label: String?, type: SupportedActionType)

    var primaryName: String { get }

    var aliases: Set<String> { get }

    var parameters: [Parameter] { get }

    func matches(action: HyperViewAction) -> Bool

    #if canImport(SwiftCodeGen)
    func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement
    #endif
}

public extension UIElementAction {
    func matches(action: HyperViewAction) -> Bool {
        return primaryName == action.eventName || aliases.contains(action.eventName)
    }
}

public class ViewTapAction: UIElementAction {
    public let primaryName = "tap"

    public let aliases: Set<String> = []

    public let parameters: [Parameter] = []

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        return .expression(.invoke(target: .constant("GestureRecognizerObserver.bindTap"), arguments: [
            MethodArgument(name: "to", value: view),
            MethodArgument(name: "handler", value: .closure(handler.listener)),
        ]))
    }
    #endif
}

/**
 * The most basic UI element protocol that every UI element should conform to.
 * UI elements usually conform to this protocol through `UIElement` or `View`.
 * Allows for more customization than conforming to `UIElement` directly.
 */
public protocol UIElementBase {
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }
    var handledActions: [HyperViewAction] { get set }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }

    func supportedActions(context: ComponentContext) throws -> [UIElementAction]
}

public struct StateProperty {
    public var name: String
    public var property: Property
    public var kind: Kind
    public var defaultValue: SupportedPropertyType

    public enum Kind {
        case factory(SupportedTypeFactory)
        case value(SupportedPropertyType)
        case raw(RawSupportedType)

        public var typeFactory: SupportedTypeFactory {
            switch self {
            case .factory(let factory):
                return factory
            case .value(let value):
                return value.stateProperty?.factory ?? value.factory
            case .raw(let value):
                return value.factory
            }
        }
    }

    public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        switch kind {
        case .factory(let factory):
            return factory.runtimeType(for: platform)
        case .value(let value):
            return value.stateProperty?.factory.runtimeType(for: platform) ?? value.factory.runtimeType(for: platform)
        case .raw(let value):
            return value.factory.runtimeType(for: platform)
        }
    }
}

public extension UIElementBase {
    var allStateProperties: [(element: UIElementBase, properties: [StateProperty])] {
        let stateProperties = [(element: self as UIElementBase, properties: properties.compactMap { property -> StateProperty? in
            switch property.anyValue {
            case .value(let value):
                return value.stateProperty.map {
                    StateProperty(
                        name: $0.name,
                        property: property,
                        kind: .value(value),
                        defaultValue: $0.defaultValue ?? property.anyDescription.anyDefaultValue)
                }
            case .state(let name, let factory):
                return StateProperty(
                    name: name,
                    property: property,
                    kind: .factory(factory),
                    defaultValue: property.anyDescription.anyDefaultValue)
            case .raw(let value):
                return value.stateProperty.map {
                    StateProperty(
                        name: $0.name,
                        property: property,
                        kind: .raw(value),
                        defaultValue: $0.defaultValue ?? property.anyDescription.anyDefaultValue)
                }
            }
        })]

        if let container = self as? UIContainer {
            return stateProperties + container.children.flatMap { $0.allStateProperties }
        } else {
            return stateProperties
        }
    }
}

public enum UIElementID: CustomStringConvertible, Hashable, Comparable {
    case provided(String)
    case generated(String)

    public var description: String {
        switch self {
        case .provided(let id):
            return id
        case .generated(let id):
            return id
        }
    }

    public static func < (lhs: UIElementID, rhs: UIElementID) -> Bool {
        switch (lhs, rhs) {
        case (.provided(let lhsId), .provided(let rhsId)):
            return lhsId < rhsId
        case (.generated(let lhsId), .generated(let rhsId)):
            return lhsId < rhsId
        case (.provided, .generated):
            return true
        case (.generated, .provided):
            return false
        }
    }
}

extension UIElementID: XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) throws -> UIElementID {
        return .provided(attribute.text)
    }
}

public struct UIElementInjectionOptions: OptionSet, XMLAttributeDeserializable {
    public static let injected = UIElementInjectionOptions(rawValue: 1 << 0)
    public static let generic: UIElementInjectionOptions = [UIElementInjectionOptions(rawValue: 1 << 1), injected]
    #warning("TODO Add support for state injected views.")
//    public static let state = UIElementInjectionOptions(rawValue: 1 << 2)
    public static let initializer = UIElementInjectionOptions(rawValue: 1 << 3)
    public static let none: UIElementInjectionOptions = []

    private static let mapping: [String: UIElementInjectionOptions] = [
        "true": injected,
        "injected": injected,
        "generic": generic,
//        "state": state,
        "init": initializer,
    ]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static func deserialize(_ attribute: XMLAttribute) throws -> UIElementInjectionOptions {
        let splitValue = attribute.text.components(separatedBy: "|")

        let reducedValue: UIElementInjectionOptions = try splitValue.reduce([]) { accumulator, value in
            guard let mappedValue = mapping[value] else {
                throw TokenizationError(
                    message: "Unsupported value <\(value)> for UIElementInjectionOptions. Supported values: \(mapping.keys.joined(separator: ", "))")
            }

            return accumulator.union(mappedValue)
        }

        #warning("TODO Uncomment when state injection is added.")
        if /*!reducedValue.contains(.state) &&*/ !reducedValue.contains(.initializer) {
            return reducedValue.union(.initializer)
        } else {
            return reducedValue
        }
    }
}

/**
 * Contains the interface to a real UI element (layout, styling).
 * Conforming to this protocol is sufficient on its own when creating a UI element.
 */
public protocol UIElement: AnyObject, UIElementBase, XMLElementSerializable {
    var factory: UIElementFactory { get }

    var id: UIElementID { get }
    var isExported: Bool { get }
    var injectionOptions: UIElementInjectionOptions { get }
    var layout: Layout { get set }
    var styles: [StyleName] { get set }
    var runtimeTypeOverride: RuntimeType? { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType
}

extension UIElement {
    public static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.high, ConstraintPriority.high)
    }
    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.low, ConstraintPriority.low)
    }
}

#if canImport(SwiftCodeGen)
public protocol ProvidesCodeInitialization {
    var extraDeclarations: [Structure] { get }

    func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression
}

public extension ProvidesCodeInitialization {
    var extraDeclarations: [Structure] {
        return []
    }
}
#endif

#if canImport(UIKit)
public protocol CanInitializeUIKitView {
    func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView
}
#endif

#if HyperdriveRuntime && canImport(AppKit)
public protocol CanInitializeAppKitView {
    func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView
}
#endif
