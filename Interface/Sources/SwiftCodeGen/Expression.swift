//
//  Expression.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public enum Expression: Describable {
    case constant(String)
    case closure(Closure)
    indirect case member(target: Expression, name: String)
    indirect case invoke(target: Expression, arguments: [MethodArgument])
    indirect case `operator`(lhs: Expression, operator: String, rhs: Expression)
    indirect case arrayLiteral(items: [Expression])
    indirect case dictionaryLiteral(items: [(key: Expression, value: Expression)])

    public func describe(into pipe: DescriptionPipe) {
        switch self {
        case .constant(let constant):
            pipe.string(constant)
        case .closure(let closure):
            pipe.append(closure)
        case .member(let target, let name):
            pipe.append(target).string(".").string(name)
        case .invoke(let target, let arguments):
            pipe.append(target).string("(")
            for (index, argument) in arguments.enumerated() {
                if index > 0 {
                    pipe.string(", ")
                }
                if let name = argument.name {
                    pipe.string(name).string(": ")
                }
                pipe.append(argument.value)
            }
            pipe.string(")")
        case .operator(let lhs, let op, let rhs):
            pipe.append(lhs).string(op).append(rhs)
        case .arrayLiteral(let items):
            guard !items.isEmpty else {
                pipe.string("[]")
                break
            }

            pipe.block(encapsulateIn: .brackets) {
                for item in items {
                    pipe.append(item).lineEnd(",")
                }
            }

        case .dictionaryLiteral(let items):
            guard !items.isEmpty else {
                pipe.string("[:]")
                break
            }

            pipe.block(encapsulateIn: .brackets) {
                for (key, value) in items {
                    pipe.append(key).string(": ").append(value).lineEnd(",")
                }
            }
        }
    }

    public static func join(expressions: [Expression], operator: String) -> Expression? {
        guard let firstExpression = expressions.first else { return nil }

        return expressions.dropFirst().reduce(firstExpression) { lhs, rhs in
            Expression.operator(lhs: lhs, operator: `operator`, rhs: rhs)
        }
    }
}
