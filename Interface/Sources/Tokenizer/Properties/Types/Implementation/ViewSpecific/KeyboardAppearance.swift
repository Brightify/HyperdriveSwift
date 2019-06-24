//
//  KeyboardAppearance.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum KeyboardAppearance: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIKeyboardAppearance"
    public static let typeFactory = TypeFactory()

    case `default`
    case dark
    case light
}

extension KeyboardAppearance {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = KeyboardAppearance

        public init() { }
    }
}

#if canImport(UIKit)
    import UIKit

    extension KeyboardAppearance {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .`default`:
                return UIKeyboardAppearance.default.rawValue
            case .dark:
                return UIKeyboardAppearance.dark.rawValue
            case .light:
                return UIKeyboardAppearance.light.rawValue
            }
        }
    }
#endif
