//
//  Closure.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Closure: Describable {
    public struct Capture: Describable {
        public enum Kind {
            case strong
            case weak
            case unowned
        }

        public let kind: Kind
        public let captured: Expression

        public func describe(into pipe: DescriptionPipe) {
            switch kind {
            case .strong:
                break
            case .weak:
                pipe.string("weak ")
            case .unowned:
                pipe.string("unowned ")
            }

            pipe.append(captured)
        }

        public static func strong(_ captured: Expression) -> Capture {
            return Capture(kind: .strong, captured: captured)
        }

        public static func weak(_ captured: Expression) -> Capture {
            return Capture(kind: .weak, captured: captured)
        }

        public static func unowned(_ captured: Expression) -> Capture {
            return Capture(kind: .unowned, captured: captured)
        }
    }

    public let captures: [Capture]
    public let parameters: [(name: String?, type: String?)]
    public let returnType: String?
    public let block: Block

    public init(captures: [Capture] = [], parameters: [(name: String?, type: String?)] = [], returnType: String? = nil, block: Block) {
        self.captures = captures
        self.parameters = parameters
        self.returnType = returnType
        self.block = block
    }

    public init(captures: [Capture] = [], parameters: [String], returnType: String? = nil, block: Block) {
        self.init(captures: captures, parameters: parameters.map { (name: $0, type: nil) }, returnType: returnType, block: block)
    }

    public func describe(into pipe: DescriptionPipe) {
        pipe.string("{")

        var hasHeader = false

        if !captures.isEmpty {
            hasHeader = true
            pipe.string(" [")
            for (index, capture) in captures.enumerated() {
                if index > 0 {
                    pipe.string(", ")
                }
                pipe.append(capture)
            }
            pipe.string("]")
        }

        if !parameters.isEmpty {
            pipe.string(" ")
            hasHeader = true
            let needsWrapping = parameters.contains { $0.type != nil }
            if needsWrapping {
                pipe.string("(")
            }
            for (index, parameter) in parameters.enumerated() {
                if index > 0 {
                    pipe.string(", ")
                }

                let (name, type) = parameter
                pipe.string(name ?? "_")

                if let type = type {
                    pipe.string(": \(type)")
                }
            }
            if needsWrapping {
                pipe.string(")")
            }
        }

        if let returnType = returnType {
            hasHeader = true

            pipe.string(" -> \(returnType)")
        }

        if hasHeader {
            pipe.string(" in")
        }
        pipe.lineEnd()

        pipe.indented {
            pipe.append(block)
        }
        pipe.string("}")
    }
}
