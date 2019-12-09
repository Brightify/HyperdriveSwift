//
//  Structure.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Structure: ContainerType, HasAttributes, HasAccessibility {
    public enum Kind: CustomStringConvertible {
        case `struct`
        case `class`(isFinal: Bool)
        case `enum`(cases: [EnumCase])
        case `extension`

        public var description: String {
            switch self {
            case .struct:
                return "struct"
            case .class(isFinal: true):
                return "final class"
            case .class(isFinal: false):
                return "class"
            case .enum:
                return "enum"
            case .extension:
                return "extension"
            }
        }

        public var cases: [EnumCase] {
            switch self {
            case .struct, .class, .extension:
                return []
            case .enum(let cases):
                return cases
            }
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var kind: Kind
    public var name: String
    public var genericParameters: [GenericParameter]
    public var inheritances: [String]
    public var whereClause: [String]
    public var containers: [ContainerType]
    public var properties: [Property]
    public var functions: [Function]

    public static func `class`(attributes: Attributes = [], accessibility: Accessibility = .internal, isFinal: Bool = false, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .class(isFinal: isFinal),
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `struct`(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .struct,
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `enum`(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], cases: [EnumCase], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .enum(cases: cases),
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `extension`(attributes: Attributes = [], accessibility: Accessibility = .internal, extendedType: String, inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .extension,
            name: extendedType,
            genericParameters: [],
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public func describe(into pipe: DescriptionPipe) {
        let inheritancesString = inheritances.joined(separator: ", ")
        attributes.describe(into: pipe)
        let genericParametersString = genericParameters.map { $0.description }.joined(separator: ", ")
        pipe.string([accessibility.description, "\(kind) \(name)\(genericParameters.isEmpty ? "" : "<\(genericParametersString)>")\(!inheritancesString.isEmpty ? ": \(inheritancesString)" : "")"].filter { !$0.isEmpty }.joined(separator: " "))
        pipe.string(" ")
        pipe.block {
            pipe.spaced(linePadding: 1, describables: [
                (linePadding: 0, describables: containers),
                (linePadding: 0, kind.cases),
                (linePadding: 0, describables: properties),
                (linePadding: 1, describables: functions),
            ])
        }
    }
}
