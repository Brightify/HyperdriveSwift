//
//  SpellCheckingType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

import Foundation

public enum SpellCheckingType: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextSpellCheckingType"
    public static let typeFactory = TypeFactory()

    case `default`
    case no
    case yes

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = SpellCheckingType

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension SpellCheckingType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .`default`:
            return UITextSpellCheckingType.default.rawValue
        case .no:
            return UITextSpellCheckingType.no.rawValue
        case .yes:
            return UITextSpellCheckingType.yes.rawValue
        }
    }
}
#endif
