//
//  AttributedTextStyle.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

/**
 * Structure representing a single tag inside an <attributedTextStyle> element within `StyleGroup` (<styles>).
 */
public struct AttributedTextStyle: XMLElementDeserializable {
    public var name: String
    public var accessModifier: AccessModifier
    public var properties: [Property] {
        didSet {
            recalculatePropertyNames()
        }
    }
    public private(set) var propertyNames: Set<String> = []

    init(node: XMLElement) throws {
        name = node.name
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }
        properties = try PropertyHelper.deserializeSupportedProperties(properties: Module.Foundation.Properties.attributedText.allProperties, in: node) as [Property]
    }

    mutating func extend(with extensionProperties: [Property]) {
        properties = (extensionProperties + properties).distinctLast(comparator: {
            $0.name == $1.name
        })
    }

    /**
     * Checks if any of Style's properties require theming.
     * - parameter context: context to use
     * - returns: `Bool` whether or not any of its properties require theming
     */
    public func requiresTheme(context: DataContext) -> Bool {
        return properties.contains(where: { $0.anyValue.requiresTheme(context: context) })
    }

    public static func deserialize(_ element: XMLElement) throws -> AttributedTextStyle {
        return try AttributedTextStyle(node: element)
    }

    private mutating func recalculatePropertyNames() {
        propertyNames = Set(properties.map { $0.name })
    }
}
