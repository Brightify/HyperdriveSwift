//
//  ComponentDefinitionAction.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public class ComponentDefinitionAction: UIElementAction {
    public let primaryName: String

    public let aliases: Set<String> = []

    public let parameters: [Parameter]

    init(action: ResolvedHyperViewAction) {
        primaryName = action.name
        parameters = action.parameters.map { parameter in
            Parameter(label: parameter.label, type: parameter.type)
        }
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        let listener = Closure(captures: handler.captures, parameters: [(name: "action", type: nil)], block: [
            .if(condition: [.enumUnwrap(case: primaryName, parameters: handler.innerParameters, expression: .constant("action"))], then: [handler.publisher], else: nil)
            ])

        return .expression(.invoke(target: .member(target: view, name: "actionPublisher.listen"), arguments: [
            MethodArgument(name: "with", value: .closure(listener)),
        ]))
    }
    #endif
}
