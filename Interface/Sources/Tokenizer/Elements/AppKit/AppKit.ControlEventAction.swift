//
//  AppKit.ControlEventAction.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Module.AppKit {
    public class ControlEventAction: UIElementAction {
        public let primaryName: String
        public let aliases: Set<String>
        public let parameters: [Parameter]

        public init(name: String, aliases: Set<String> = [], parameters: [Parameter] = []) {
            self.primaryName = name
            self.aliases = aliases
            self.parameters = parameters
        }

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif
    }

    public class VoidControlEventAction: UIElementAction {
        public let primaryName = "event"
        public let aliases: Set<String> = ["controlEvent"]
        public let parameters: [Parameter] = []

        public init() {}

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif
    }

    public class TextEventAction: UIElementAction {
        public let primaryName = "text"
        public let aliases: Set<String> = ["textChanged"]
        public let parameters: [Parameter] = [Parameter(label: "text", type: .propertyType(String.typeFactory))]

        public init() {}

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            return .expression(.invoke(target: .constant("HyperdriveInterface.NSTextFieldObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif
    }

    public class ValueEventAction: UIElementAction {
        public enum ValueType: String {
            case int = "integerValue"
            case string = "stringValue"
            case float = "floatValue"
            case double = "doubleValue"

            var typeFactory: SupportedTypeFactory {
                switch self {
                case .int:
                    return Int.typeFactory
                case .string:
                    return String.typeFactory
                case .float:
                    return Float.typeFactory
                case .double:
                    return Double.typeFactory
                }
            }
        }

        public let primaryName: String
        public let aliases: Set<String>
        public let parameters: [Parameter]

        public init(name: String, aliases: Set<String> = [], label: String? = nil, valueType: ValueType) {
            self.primaryName = name
            self.aliases = aliases
            self.parameters = [Parameter(label: "control", propertyName: valueType.rawValue, type: .propertyType(valueType.typeFactory))]
        }

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif
    }
}
