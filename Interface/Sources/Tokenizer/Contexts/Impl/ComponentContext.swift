//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

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
        return component.stylesName + "." + name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .local(let name) = styleName else {
            return globalContext.style(named: styleName)
        }
        return component.styles.first { $0.name.name == name }.flatMap { try? Style(from: $0, context: self) }
    }

    public func resolve(actions: [(element: UIElementBase, actions: [HyperViewAction])]) throws -> [ResolvedHyperViewAction] {
        let elementActions: [(element: UIElementBase, action: HyperViewAction, elementAction: UIElementAction)] = try actions.flatMap { element, actions in
            try actions.compactMap { action in
                guard let elementAction = try element.supportedActions(context: self).first(where: { $0.matches(action: action) }) else { return nil }
                return (element: element, action: action, elementAction: elementAction)
            }
        }

        #warning("Compute state once in init, not here for improved performance")
        let state = try globalContext.resolve(state: component)

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
                        $0.runtimeType(for: platform).name == type && $0 is AttributeSupportedPropertyType.Type
                    }) as? AttributeSupportedPropertyType.Type else {
                        throw TokenizationError(message: "Unknown type \(type) for value \(value)")
                    }

                    let typedValue = try foundType.materialize(from: value)

                return [ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value: typedValue))]
//                    return ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value: ))
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
                        return try [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(view: targetId, property: nil, type: .elementReference(targetElement.runtimeType(for: platform))))]
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

    public func child(for definition: ComponentDefinition) -> ComponentContext {
        return ComponentContext(globalContext: globalContext, component: definition)
    }
}

extension ComponentContext: HasGlobalContext, HasParentContext { }

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif
