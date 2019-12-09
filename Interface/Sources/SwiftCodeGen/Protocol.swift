//
//  Protocol.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Protocol: ContainerType, HasAttributes, HasAccessibility {
    public struct ProtocolProperty: Describable {
        public enum PropertyType {
            case get
            case getSet

            public var description: String {
                switch self {
                case .get:
                    return "get"
                case .getSet:
                    return "get set"
                }
            }
        }

        public var attributes: Attributes
        public var accessibility: Accessibility
        public var modifiers: DeclarationModifiers
        public var name: String
        public var type: String
        public var propertyType: PropertyType

        public init(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, propertyType: PropertyType) {
            self.attributes = attributes
            self.accessibility = accessibility
            self.modifiers = modifiers
            self.name = name
            self.type = type
            self.propertyType = propertyType
        }

        public static func from(property: Property, propertyTypeHint: PropertyType? = nil) throws -> ProtocolProperty {
            guard let type = property.type else {
                throw GenerationError.missingField
            }
            let propertyType = propertyTypeHint ?? (property.isConstant && property.block == nil ? .get : .getSet)
            return ProtocolProperty(attributes: property.attributes, accessibility: property.accessibility, modifiers: property.modifiers, name: property.name, type: type, propertyType: propertyType)
        }

        public func describe(into pipe: DescriptionPipe) {
            attributes.describe(into: pipe)
            pipe.line([accessibility.description, modifiers.description, "var", "\(name): \(type)", "{ \(propertyType.description) }"].filter { !$0.isEmpty }.joined(separator: " "))
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var name: String
    public var genericParameters: [(name: String, inheritance: String?)]
    public var inheritances: [String]
    public var properties: [ProtocolProperty]
    public var functions: [Function]

    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [(name: String, inheritance: String?)] = [], inheritances: [String] = [], properties: [ProtocolProperty] = [], functions: [Function] = []) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.name = name
        self.genericParameters = genericParameters
        self.inheritances = inheritances
        self.properties = properties
        self.functions = functions
    }

    public func describe(into pipe: DescriptionPipe) {
        let inheritancesString = inheritances.joined(separator: ", ")
        attributes.describe(into: pipe)
        pipe.string([accessibility.description, "protocol \(name)\(inheritancesString.isEmpty ? inheritancesString : "")"].filter { !$0.isEmpty }.joined(separator: " "))
        pipe.string(" ")
        pipe.block {
            pipe.lines(genericParameters.map { "associatedtype \($0.name)\($0.inheritance.format(into: { ": \($0)" }))" })
            pipe.line()
            pipe.spaced(linePadding: 0, describables: properties)
            pipe.line()
            for (index, function) in functions.enumerated() {
                function.describe(into: pipe, shouldOmitBody: true)
                if index != functions.endIndex - 1 {
                    pipe.line()
                }
            }
        }
    }
}
