//
//  Template.swift
//  Example
//
//  Created by Robin Krenecky on 05/10/2018.
//

import Foundation
#if canImport(UIKit)
import HyperdriveInterface
#endif

/**
 * Structure representing an XML template.
 *
 * Example:
 * ```
 *  <templates>
 *      <attributedText style="attributedStyle" name="superTemplate">
 *          <b>Hello</b> {{name}}, {{foo}}
 *      </attributedText>
 *  </templates>
 * ```
 */
public struct Template: XMLElementDeserializable {
    public var name: TemplateName
    public var extend: [TemplateName]
    public var parentModuleImport: String
    public var properties: [Property]
    public var type: TemplateType

    init(node: XMLElement, groupName: String?) throws {
        let name = try node.value(ofAttribute: "name") as String
        let extendedStyles = try node.value(ofAttribute: "extend", defaultValue: []) as [TemplateName]
        if let groupName = groupName {
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

        if node.name == "attributedText" {
            parentModuleImport = "HyperdriveInterface"
            properties = try PropertyHelper.deserializeSupportedProperties(properties: Module.Foundation.Properties.attributedText.allProperties, in: node) as [Property]
            type = .attributedText(template: try AttributedTextTemplate(node: node))
        } else {
            throw TokenizationError(message: "Unknown template \(node.name). (\(node))")
        }
    }

    /**
     * Checks if any of Template's properties require theming.
     * - parameter context: context to use
     * - returns: `Bool` whether or not any of its properties require theming
     */
    public func requiresTheme(context: DataContext) -> Bool {
        return properties.contains(where: { $0.anyValue.requiresTheme }) ||
            extend.contains(where: {
                context.template(named: $0)?.requiresTheme(context: context) == true
            })
    }

    /**
     * Tries to create the `Template` structure from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, `Template` obtained from the passed XML element
     */
    public static func deserialize(_ element: XMLElement) throws -> Template {
        return try Template(node: element, groupName: nil)
    }
}
