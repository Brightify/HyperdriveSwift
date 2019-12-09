//
//  Structure+EnumCase.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

extension Structure {
    public struct EnumCase: Describable {
        public typealias Argument = (name: String?, type: String)

        public var isIndirect: Bool
        public var name: String
        public var arguments: [Argument]

        public func describe(into pipe: DescriptionPipe) {
            let argumentsString: String
            if arguments.isEmpty {
                argumentsString = ""
            } else {
                let mappedArguments = arguments.map { argument in
                    argument.name.format(into: { "\($0): " }) + argument.type
                }
                argumentsString = "(\(mappedArguments.joined(separator: ", ")))"
            }
            pipe.line("case \(name)\(argumentsString)")
        }

        public init(name: String, arguments: [Argument] = []) {
            self.init(isIndirect: false, name: name, arguments: arguments)
        }

        private init(isIndirect: Bool, name: String, arguments: [Argument]) {
            self.isIndirect = isIndirect
            self.name = name
            self.arguments = arguments
        }

        public static func indirect(name: String, arguments: [Argument]) -> EnumCase {
            return EnumCase(isIndirect: true, name: name, arguments: arguments)
        }
    }
}
