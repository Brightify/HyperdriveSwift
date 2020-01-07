//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

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

// This class is identical to AppKit's ComponentReference. If you make any changes here, you might want to make them there, too.
//extension Module.UIKit {
    public class ComponentReference: UIElement, ComponentDefinitionContainer {
        public var factory: UIElementFactory {
            return backingView.factory
        }

        public var id: UIElementID {
            return backingView.id
        }

        public var isExported: Bool {
            return backingView.isExported
        }

        public var injectionOptions: UIElementInjectionOptions {
            return backingView.injectionOptions
        }

        public var layout: Layout {
            get {
                return backingView.layout
            }
            set {
                backingView.layout = newValue
            }
        }

        public var styles: [StyleName] {
            get {
                return backingView.styles
            }
            set {
                backingView.styles = newValue
            }
        }

        public var properties: [Property] {
            get {
                return backingView.properties
            }
            set {
                backingView.properties = newValue
            }
        }

        public var toolingProperties: [String : Property] {
            get {
                return backingView.toolingProperties
            }
            set {
                backingView.toolingProperties = newValue
            }
        }

        public var handledActions: [HyperViewAction] {
            get {
                return backingView.handledActions
            }
            set {
                backingView.handledActions = newValue
            }
        }

        public static var parentModuleImport: String = ""

        public var requiredImports: Set<String> {
            return backingView.requiredImports
        }

        public enum StatePassthrough {
            case property(String)
            case exported
        }

        public var backingView: UIElement
        public var module: String?
        public var type: String
        public var definition: ComponentDefinition?
        public var passthroughActions: String?
        public var passthroughState: StatePassthrough?
        public var possibleStateProperties: [String: String]

        public func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            let definition = try self.definition ?? context.definition(for: type)

            let actions = try context.child(for: definition).resolve(actions: definition.providedActions).map(ComponentDefinitionAction.init)

            let passthrough: [UIElementAction] = passthroughActions.map { _ in [ComponentReferencePassthroughAction(type: type)] } ?? []

            return try passthrough + actions + backingView.supportedActions(context: context)
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

        public class func runtimeType() throws -> String {
            return "UIView"
        }

        public func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            return RuntimeType(name: type, modules: module.map { [$0] } ?? [])
        }

        public required init(context: UIElementDeserializationContext, backingView: UIElement, factory: UIElementFactory) throws {
            let node = context.element
            type = try node.value(ofAttribute: "type", defaultValue: node.name)
            guard type != "Component" else { throw TokenizationError(message: "Name `Component` is not allowed for component reference!") }

            if !node.xmlChildren.isEmpty {
                definition = try context.deserialize(element: node, type: type)
            } else {
                definition = nil
            }

            passthroughActions = node.attribute(by: "action")?.text
            // not used. reason?
//            let viewProperties = Set(ComponentReference.availableProperties.map { $0.name })
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

            self.backingView = backingView

            if let passthrough = passthroughActions {
                handledActions.append(HyperViewAction(name: passthrough, eventName: "#passthrough#", parameters: [(label: nil, parameter: .inheritedParameters)]))
            }
        }

        // dead code? perhaps, `UIKit.View`'s init() is armed for crash, so this is redundant
//        public init(type: String, definition: ComponentDefinition?) {
//            self.type = type
//            self.definition = definition
//            self.possibleStateProperties = [:]
//            self.passthroughState = nil
//
//            super.init()
//        }

        #if canImport(UIKit)
        public func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            return try context.componentInstantiation(named: type)()
        }
        #endif

        #if HyperdriveRuntime && canImport(AppKit)
        public func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView {
            return try context.componentInstantiation(named: type)()
        }
        #endif

        public func serialize(context: DataContext) -> XMLSerializableElement {
            var serialized = backingView.serialize(context: context)
            #warning("TODO: Fix element serialization")
    //        if let type = type {
                serialized.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)
    //        }
            return serialized
        }
    }
//}

#if canImport(SwiftCodeGen)
extension ComponentReference: ProvidesCodeInitialization {
    public func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression {
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
}
#endif
