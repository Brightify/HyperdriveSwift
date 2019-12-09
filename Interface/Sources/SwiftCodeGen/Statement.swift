//
//  Statement.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public enum Statement: Describable {
    case assignment(target: Expression, expression: Expression)
    case `return`(expression: Expression?)
    case declaration(isConstant: Bool, name: String, expression: Expression?)
    case expression(Expression)
    case `guard`(conditions: [ConditionExpression], else: Block)
    case `if`(condition: [ConditionExpression], then: Block, else: Block?)
    case `switch`(expression: Expression, cases: [(Expression, Block)], default: Block?)
    case emptyLine

    public static func variable(name: String, expression: Expression) -> Statement {
        return .declaration(isConstant: false, name: name, expression: expression)
    }

    public static func constant(name: String, expression: Expression) -> Statement {
        return .declaration(isConstant: true, name: name, expression: expression)
    }

    public func describe(into pipe: DescriptionPipe) {
        switch self {
        case .assignment(let target, let expression):
            pipe.append(target).string(" = ").append(expression)
        case .return(let expression):
            pipe.string("return")
            if let expression = expression {
                pipe.string(" ").append(expression)
            }
        case .declaration(let isConstant, let name, let expression):
            pipe.string(isConstant ? "let " : "var ").string(name)
            if let expression = expression {
                pipe.string(" = ").append(expression)
            }
        case .expression(let expression):
            pipe.append(expression)
        case .guard(let conditions, let elseBlock):
            pipe.string("guard ")
            for (index, condition) in conditions.enumerated() {
                if index > 0 {
                    pipe.string(", ")
                }
                pipe.append(condition)
            }
            pipe.block(line: " else") {
                pipe.append(elseBlock)
            }
        case .if(let conditions, let thenBlock, let elseBlock):
            pipe.string("if ")
            for (index, condition) in conditions.enumerated() {
                if index > 0 {
                    pipe.string(", ")
                }
                pipe.append(condition)
            }
            pipe.lineEnd(" {").indented {
                pipe.append(thenBlock)
            }.string("}")
            if let elseBlock = elseBlock {
                if case .if? = elseBlock.statements.first, elseBlock.isSingleStatement {
                    pipe.string(" else ").append(elseBlock)
                } else {
                    pipe.string(" else ").block {
                        pipe.append(elseBlock)
                    }
                }
            } else {
                pipe.lineEnd()
            }

        case .switch(let expression, let cases, let defaultBlock):
            pipe.string("switch ").append(expression).lineEnd(" {")

            for (caseExpresison, caseBlock) in cases {
                pipe.string("case ").append(caseExpresison).string(":")
                if caseBlock.isSingleStatement {
                    pipe.string(" ").append(caseBlock).lineEnd()
                } else {
                    pipe.indented {
                        pipe.append(caseBlock)
                    }
                }
            }

            if let defaultBlock = defaultBlock {
                pipe.string("default:")
                if defaultBlock.isSingleStatement {
                    pipe.string(" ").append(defaultBlock).lineEnd()
                } else {
                    pipe.indented {
                        pipe.append(defaultBlock)
                    }
                }
            }

            pipe.line("}")
        case .emptyLine:
            pipe.line()
        }
    }
}
