//
//  KeyboardAppearance.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum KeyboardAppearance: String, EnumPropertyType {
    public static let enumName = "UIKeyboardAppearance"
    public static let typeFactory = EnumTypeFactory<KeyboardAppearance>()

    case `default`
    case dark
    case light
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
