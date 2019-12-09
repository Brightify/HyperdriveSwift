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
    public var properties: [Property]

    init(node: XMLElement) throws {
        name = node.name
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }
        properties = try PropertyHelper.deserializeSupportedProperties(properties: Module.Foundation.Properties.attributedText.allProperties, in: node) as [Property]
    }

    public static func deserialize(_ element: XMLElement) throws -> AttributedTextStyle {
        return try AttributedTextStyle(node: element)
    }
}
