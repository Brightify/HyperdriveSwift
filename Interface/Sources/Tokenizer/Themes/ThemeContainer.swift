//
//  ThemeContainer.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

/**
 * Structure containing themed resources.
 * An example would be themed XML element **<Fonts>** (and its innards) inside an **<Application>** XML element.
 */
public struct ThemeContainer<T: HasStaticTypeFactory>: XMLElementDeserializable where T.TypeFactory: TypedAttributeSupportedTypeFactory {
    public typealias ItemName = String

    private var defaultItems: [ItemName: T] = [:]
    private var themedItems: [ItemName: [ApplicationDescription.ThemeName: T]] = [:]

    /**
     * Given a theme and an item name returns its property type.
     * - parameter theme: theme to use
     * - parameter item: item to get using the passed theme
     * - returns: property type corresponding to passed theme and item if present, otherwise nil
     */
    public subscript(theme theme: String, item item: String) -> T? {
        return themedItems[item]?[theme] ?? defaultItems[item]
    }

    /**
     * A `Set` of all themed items inside the theme container.
     */
    public var allItemNames: Set<ItemName> {
        let defaultItemNames = defaultItems.keys
        let themedItemNames = themedItems.keys
        return Set(defaultItemNames).union(themedItemNames)
    }

    public init() { }

    public init(node: XMLElement) throws {
        for child in node.xmlChildren {
            for (theme, attribute) in child.allAttributes {
                let item = try T.typeFactory.materialize(from: attribute.text)
                if theme == "default" {
                    defaultItems[child.name] = item
                } else {
                    themedItems[child.name, default: [:]][theme] = item
                }
            }
        }
    }

    /**
     * Tries to deserialize the `ThemeContainer` from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, the `ThemeContainer` structure
     */
    public static func deserialize(_ element: XMLElement) throws -> ThemeContainer<T> {
        return try ThemeContainer(node: element)
    }
}
