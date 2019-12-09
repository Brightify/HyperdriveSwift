//
//  DeclarationModifiers.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct DeclarationModifiers: OptionSet {
    public let rawValue: Int

    public static let convenience = DeclarationModifiers(rawValue: 1 << 0)
    public static let dynamic = DeclarationModifiers(rawValue: 1 << 1)
    public static let final = DeclarationModifiers(rawValue: 1 << 2)
    public static let infix = DeclarationModifiers(rawValue: 1 << 3)
    public static let lazy = DeclarationModifiers(rawValue: 1 << 4)
    public static let optional = DeclarationModifiers(rawValue: 1 << 5)
    public static let override = DeclarationModifiers(rawValue: 1 << 6)
    public static let postfix = DeclarationModifiers(rawValue: 1 << 7)
    public static let prefix = DeclarationModifiers(rawValue: 1 << 8)
    public static let required = DeclarationModifiers(rawValue: 1 << 9)
    public static let `static` = DeclarationModifiers(rawValue: 1 << 10)
    public static let unowned = DeclarationModifiers(rawValue: 1 << 11)
    public static let weak = DeclarationModifiers(rawValue: 1 << 12)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    private static let allValuesWithDescriptions: [(modifier: DeclarationModifiers, description: String)] = [
        (.convenience, "convenience"),
        (.dynamic, "dynamic"),
        (.final, "final"),
        (.infix, "infix"),
        (.lazy, "lazy"),
        (.optional, "optional"),
        (.override, "override"),
        (.postfix, "postfix"),
        (.prefix, "prefix"),
        (.required, "required"),
        (.static, "static"),
        (.unowned, "unowned"),
        (.weak, "weak"),
    ]

    public var description: String {
        return DeclarationModifiers.allValuesWithDescriptions
            .filter { contains($0.modifier) }
            .map { $0.description }
            .joined(separator: " ")
    }
}
