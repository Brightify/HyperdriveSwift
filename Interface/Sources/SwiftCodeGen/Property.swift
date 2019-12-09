//
//  Property.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Property: HasAttributes, HasAccessibility, HasModifiers, Describable {
    public var attributes: Attributes
    public var accessibility: Accessibility
    public var modifiers: DeclarationModifiers
    public var isConstant: Bool
    public var name: String
    public var type: String?
    public var value: Expression?
    public var block: Block?

    public static func variable(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String? = nil, value: Expression) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: false,
            name: name,
            type: type,
            value: value,
            block: nil
        )
    }

    public static func variable(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, value: Expression? = nil, block: Block? = nil) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: false,
            name: name,
            type: type,
            value: value,
            block: block
        )
    }
    
    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, value: Expression) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: nil,
            value: value,
            block: nil
        )
    }

    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: type,
            value: nil,
            block: nil
        )
    }

    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, value: Expression) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: type,
            value: value,
            block: nil
        )
    }

    private init(attributes: Attributes, accessibility: Accessibility, modifiers: DeclarationModifiers, isConstant: Bool, name: String, type: String?, value: Expression?, block: Block?) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.modifiers = modifiers
        self.isConstant = isConstant
        self.name = name
        self.type = type
        self.value = value
        self.block = block
    }

    public func describe(into pipe: DescriptionPipe) {
        let typeString = type.format(into: { ": \($0)" })

        attributes.describe(into: pipe)
        pipe.string([accessibility.description, modifiers.description, "\(isConstant ? "let" : "var")", "\(name)\(typeString)"].filter { !$0.isEmpty }.joined(separator: " "))
        if let value = value {
            pipe.string(" = ").append(value)
        }

        if let block = block {
            pipe.string(" ")
            pipe.block {
                pipe.append(block)
            }
        } else {
            pipe.lineEnd()
        }
    }
}
