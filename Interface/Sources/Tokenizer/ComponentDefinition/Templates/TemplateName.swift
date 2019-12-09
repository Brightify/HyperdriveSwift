//
//  TemplateName.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

/**
 * Template identifier used to resolve the template name.
 */
public enum TemplateName: XMLAttributeDeserializable, XMLAttributeName {
    case local(name: String)
    case global(group: String, name: String)

    /**
     * Gets the `name` variable from either of the cases.
     */
    public var name: String {
        switch self {
        case .local(let name):
            return name
        case .global(_, let name):
            return name
        }
    }

    public init(from value: String) throws {
        let notationCharacter: String
        if value.contains(".") {
            notationCharacter = "."
        } else {
            notationCharacter = ":"
        }

        let components = value.components(separatedBy: notationCharacter).filter { !$0.isEmpty }
        if components.count == 2 {
            self = .global(group: components[0], name: components[1])
        } else if components.count == 1 {
            self = .local(name: components[0])
        } else {
            throw TokenizationError.invalidTemplateName(text: value)
        }
    }

    /**
     * Generates an XML `String` representation of the `TemplateName`.
     * - returns: XML `String` representation of the `TemplateName`
     */
    public func serialize() -> String {
        switch self {
        case .local(let name):
            return name
        case .global(let group, let name):
            return ":\(group):\(name)"
        }
    }

    /**
     * Tries to parse the passed XML attribute into a `TemplateName` identifier.
     * - parameter attribute: XML attribute to be parsed into `TemplateName`
     * - returns: if not thrown, the parsed `TemplateName`
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> TemplateName {
        return try TemplateName(from: attribute.text)
    }
}

extension TemplateName: Equatable {
    public static func == (lhs: TemplateName, rhs: TemplateName) -> Bool {
        switch (lhs, rhs) {
        case (.local(let lName), .local(let rName)):
            return lName == rName
        case (.global(let lGroup, let lName), .global(let rGroup, let rName)):
            return lGroup == rGroup && lName == rName
        default:
            return false
        }
    }
}

