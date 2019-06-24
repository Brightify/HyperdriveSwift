//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

public class ComponentReferencePassthroughAction: UIElementAction {
    public let primaryName = "#passthrough#"
    public let aliases: Set<String> = []
    public let parameters: [Parameter]

    public init(type: String) {
        parameters = [Parameter(label: nil, type: .componentAction(component: type))]
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        return .emptyLine
    }
    #endif
}

public class ComponentReference: View, ComponentDefinitionContainer {
    public enum StatePassthrough {
        case property(String)
        case exported
    }

    public var module: String?
    public var type: String
    public var definition: ComponentDefinition?
    public var passthroughActions: String?
    public var passthroughState: StatePassthrough?
    public var possibleStateProperties: [String: String]

    public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
        let definition = try self.definition ?? context.definition(for: type)

        let actions = try context.child(for: definition).resolve(actions: definition.providedActions).map(ComponentDefinitionAction.init)

        let passthrough: [UIElementAction] = passthroughActions.map { _ in [ComponentReferencePassthroughAction(type: type)] } ?? []

        return try passthrough + actions + super.supportedActions(context: context)
    }

    public var isAnonymous: Bool {
        return definition?.isAnonymous ?? false
    }

    public var componentTypes: [String] {
        return definition?.componentTypes ?? [type]
    }

    public var componentDefinitions: [ComponentDefinition] {
        return definition?.componentDefinitions ?? []
    }

    public class override func runtimeType() throws -> String {
        return "UIView"
    }
    
    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        return RuntimeType(name: type, modules: module.map { [$0] } ?? [])
    }

    #if canImport(SwiftCodeGen)
    public override func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression {
        let actionPublisher: MethodArgument
        if let passthrough = passthroughActions {
            actionPublisher = MethodArgument(name: "actionPublisher", value: .invoke(target: .constant("actionPublisher.map"), arguments: [
                MethodArgument(value: .closure(Closure(parameters: [(name: "action", type: nil)], block: [.return(expression: .constant(".\(passthrough)(action)"))]))),
            ]))
        } else {
            actionPublisher = MethodArgument(name: "actionPublisher", value: .constant("ActionPublisher()"))
        }

        return .invoke(target: .constant(type), arguments: [
            MethodArgument(name: "initialState", value: .constant("\(type).State()")),
            actionPublisher,
        ])
    }
    #endif

    public required init(context: UIElementDeserializationContext, factory: UIElementFactory) throws {
        let node = context.element
        type = try node.value(ofAttribute: "type", defaultValue: node.name)
        guard type != "Component" else { throw TokenizationError(message: "Name `Component` is not allowed for component reference!") }
        
        if !node.xmlChildren.isEmpty {
            definition = try context.deserialize(element: node, type: type)
        } else {
            definition = nil
        }

        passthroughActions = node.attribute(by: "action")?.text
        let viewProperties = Set(ComponentReference.availableProperties.map { $0.name })
        possibleStateProperties = Dictionary(uniqueKeysWithValues: node.allAttributes.compactMap { name, attribute -> (String, String)? in
            guard name.starts(with: "state:") else { return nil }
            return (String(name.dropFirst("state:".count)), attribute.text)
        })
        if let statePassthrough = node.attribute(by: "state")?.text {
            if statePassthrough == "*" {
                passthroughState = .exported
            } else if statePassthrough.starts(with: "$") {
                throw TokenizationError(message: "State passthrough is not currently supported. Please use * to export inner component state.")
                passthroughState = .property(String(statePassthrough.dropFirst()))
            } else {
                throw TokenizationError(message: "Invalid state attribute value \(statePassthrough)! Allowed: *, $stateProperty")
            }
        } else {
            passthroughState = nil
        }
        
        try super.init(context: context, factory: factory)

        if let passthrough = passthroughActions {
            handledActions.append(HyperViewAction(name: passthrough, eventName: "#passthrough#", parameters: [(label: nil, parameter: .inheritedParameters)]))
        }
    }
    
    public init(type: String, definition: ComponentDefinition?) {
        self.type = type
        self.definition = definition
        self.possibleStateProperties = [:]
        self.passthroughState = nil

        super.init()
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        return try context.componentInstantiation(named: type)()
    }
    #endif
    
    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var serialized = super.serialize(context: context)
        #warning("TODO: Fix element serialization")
//        if let type = type {
            serialized.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)
//        }
        return serialized
    }
}
