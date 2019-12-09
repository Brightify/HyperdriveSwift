//
//  Function.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Function: HasAttributes, HasAccessibility, HasModifiers, Describable {
    public enum ThrowType {
        case throwing
        case rethrowing

        public var description: String {
            switch self {
            case .throwing:
                return "throws"
            case .rethrowing:
                return "rethrows"
            }
        }
    }
    public enum FunctionType {
        case standard
        case initializer
        case deinitializer

        public var isInitializer: Bool {
            switch self {
            case .initializer:
                return true
            default:
                return false
            }
        }

        public var isDeinitializer: Bool {
            switch self {
            case .deinitializer:
                return true
            default:
                return false
            }
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var modifiers: DeclarationModifiers
    public var functionType: FunctionType
    public var name: String
    public var genericParameters: [GenericParameter]
    public var parameters: [MethodParameter]
    public var throwType: ThrowType?
    public var returnType: String?
    public var whereClause: [String]
    public var block: Block

    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, genericParameters: [GenericParameter] = [], parameters: [MethodParameter] = [], throwType: ThrowType? = nil, returnType: String? = nil, whereClause: [String] = [], block: Block = []) {
        self.init(attributes: attributes, accessibility: accessibility, modifiers: modifiers, functionType: .standard, name: name, genericParameters: genericParameters, parameters: parameters, throwType: throwType, returnType: returnType, whereClause: whereClause, block: block)
    }

    private init(attributes: Attributes, accessibility: Accessibility, modifiers: DeclarationModifiers, functionType: FunctionType, name: String, genericParameters: [GenericParameter], parameters: [MethodParameter], throwType: ThrowType?, returnType: String?, whereClause: [String], block: Block) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.modifiers = modifiers
        self.functionType = functionType
        self.name = name
        self.genericParameters = genericParameters
        self.parameters = parameters
        self.throwType = throwType
        self.returnType = returnType
        self.whereClause = whereClause
        self.block = block
    }

    public static func initializer(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], optionalInit: Bool = false, genericParameters: [GenericParameter] = [], parameters: [MethodParameter] = [], throwType: ThrowType? = nil, whereClause: [String] = [], block: Block = []) -> Function {
        return Function(attributes: attributes, accessibility: accessibility, modifiers: modifiers, functionType: .initializer, name: "init\(optionalInit ? "?" : "")", genericParameters: genericParameters, parameters: parameters, throwType: throwType, returnType: nil, whereClause: whereClause, block: block)
    }

    public static func deinitializer(attributes: Attributes = [], block: Block = []) -> Function {
        return Function(attributes: attributes, accessibility: .internal, modifiers: [], functionType: .deinitializer, name: "deinit", genericParameters: [], parameters: [], throwType: nil, returnType: nil, whereClause: [], block: block)
    }

    public func describe(into pipe: DescriptionPipe) {
        describe(into: pipe, shouldOmitBody: false)
    }

    public func describe(into pipe: DescriptionPipe, shouldOmitBody: Bool) {
        let genericParametersString = genericParameters.map { $0.description }.joined(separator: ", ")
        let parametersString = parameters.map { $0.description }.joined(separator: ", ")

        attributes.describe(into: pipe)
        pipe.string([
            accessibility.description,
            modifiers.description,
            "\(functionType.isInitializer || functionType.isDeinitializer ? "" : "func")",
            "\(name)\(genericParameters.isEmpty ? "" : "<\(genericParametersString)>")\(functionType.isDeinitializer ? "" : "(\(parametersString))")",
            throwType?.description,
            returnType.format(into: { "-> \($0)" })
            ].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " "))

        if !whereClause.isEmpty {
            pipe.string(" where \(whereClause.joined(separator: ", "))")
        }
        guard !shouldOmitBody else { return }
        pipe.string(" ")
        pipe.block {
            pipe.append(block)
        }
    }
}
