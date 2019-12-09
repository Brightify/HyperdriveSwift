//
//  Style.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import HyperdriveInterface
#endif

/**
 * Structure representing an XML style.
 *
 * Example:
 * ```
 * <styles name="ReactantStyles">
 *   <LabelStyle name="base" backgroundColor="white" />
 *   <ButtonStyle name="buttona"
 *     backgroundColor.highlighted="white"
 *     isUserInteractionEnabled="true" />
 *   <attributedTextStyle name="bandaska" extend="common:globalko">
 *     <i font=":bold@20" />
 *     <base foregroundColor="white" />
 *   </attributedTextStyle>
 * </styles>
 * ```
 */
public struct Style {
    public var name: StyleName
    public var extend: [StyleName]
    public var accessModifier: AccessModifier
    public var parentModuleImport: String
    public var properties: [Property]
    public var type: StyleType

    init(context: StyleDeserializationContext) throws {
        let node = context.element
        let name = try node.value(ofAttribute: "name") as String
        let extendedStyles = try node.value(ofAttribute: "extend", defaultValue: []) as [StyleName]
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }
        if let groupName = context.groupName {
            self.name = .global(group: groupName, name: name)
            self.extend = extendedStyles.map {
                if case .local(let name) = $0 {
                    return .global(group: groupName, name: name)
                } else {
                    return $0
                }
            }
        } else {
            self.name = .local(name: name)
            self.extend = extendedStyles
        }

        if node.name == "attributedTextStyle" {
            parentModuleImport = "Hyperdrive"
            properties = try PropertyHelper.deserializeSupportedProperties(properties: Module.Foundation.Properties.attributedText.allProperties, in: node) as [Property]

            type = try .attributedText(styles: node.xmlChildren.map(AttributedTextStyle.deserialize))

        } else if let elementFactory = context.factory(for: String(node.name.dropLast("Style".count))) {
            parentModuleImport = elementFactory.parentModuleImport
            properties = try PropertyHelper.deserializeSupportedProperties(properties: elementFactory.availableProperties, in: node) as [Property]
            type = .view(factory: elementFactory)
        } else {
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }
    }

    /**
     * Checks if any of Style's properties require theming.
     * - parameter context: context to use
     * - returns: `Bool` whether or not any of its properties require theming
     */
    public func requiresTheme(context: DataContext) -> Bool {
        return properties.contains(where: { $0.anyValue.requiresTheme }) ||
            extend.contains(where: {
                context.style(named: $0)?.requiresTheme(context: context) == true
            })
    }
}
