//
//  ConditionExpression.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public enum ConditionExpression: Describable {
    case expression(Expression)
    case conditionalUnwrap(isConstant: Bool, name: String, expression: Expression)
    case enumUnwrap(case: String, parameters: [String], expression: Expression)
    case `operator`(lhs: Expression, operator: String, rhs: Expression)

    public func describe(into pipe: DescriptionPipe) {
        switch self {
        case .expression(let expression):
            pipe.append(expression)
        case .conditionalUnwrap(let isConstant, let name, let expression):
            pipe.string(isConstant ? "let " : "var ").string(name).string(" = ").append(expression)
        case .enumUnwrap(let caseName, let parameters, let expression):
            pipe.string("case .").string(caseName)
            if !parameters.isEmpty {
                pipe.string("(").string(parameters.map { "let \($0)" }.joined(separator: ", ")).string(")")
            }
            pipe.string(" = ").append(expression)
        case .operator(let lhs, let op, let rhs):
            pipe.string("(").append(lhs).string(op).append(rhs).string(")")
        }
    }
}
