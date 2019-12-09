//
//  Block.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Block: ExpressibleByArrayLiteral, Describable {
    public var isSingleStatement: Bool {
        return statements.count <= 1
    }

    public var statements: [Statement]

    public init(statements: [Statement]) {
        self.statements = statements
    }

    public init(arrayLiteral elements: Statement...) {
        statements = elements
    }

    public func describe(into pipe: DescriptionPipe) {
        if let firstStatement = statements.first, isSingleStatement {
            pipe.append(firstStatement)
        } else {
            for statement in statements {
                pipe.append(statement).endOfLineIfNeeded()
            }
        }
    }

    public static func +(lhs: Block, rhs: Block) -> Block {
        return Block(statements: lhs.statements + rhs.statements)
    }

    public static func +=(lhs: inout Block, rhs: Statement) {
        lhs.statements.append(rhs)
    }

    public static func +=(lhs: inout Block, rhs: Block) {
        lhs.statements.append(contentsOf: rhs.statements)
    }
}
