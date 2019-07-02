//
//  TextBorderStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum TextBorderStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextField.BorderStyle"
    public static let typeFactory = TypeFactory()

    case none
    case line
    case bezel
    case roundedRect

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = TextBorderStyle

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension TextBorderStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .none:
            return UITextField.BorderStyle.none.rawValue
        case .line:
            return UITextField.BorderStyle.line.rawValue
        case .bezel:
            return UITextField.BorderStyle.bezel.rawValue
        case .roundedRect:
            return UITextField.BorderStyle.roundedRect.rawValue
        }
    }
}
#endif
