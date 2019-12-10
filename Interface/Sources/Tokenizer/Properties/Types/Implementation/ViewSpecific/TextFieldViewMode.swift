//
//  TextFieldViewMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum TextFieldViewMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextField.ViewMode"
    public static let typeFactory = TypeFactory()

    case never
    case whileEditing
    case unlessEditing
    case always

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = TextFieldViewMode

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension TextFieldViewMode {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .never:
            return UITextField.ViewMode.never.rawValue
        case .whileEditing:
            return UITextField.ViewMode.whileEditing.rawValue
        case .unlessEditing:
            return UITextField.ViewMode.unlessEditing.rawValue
        case .always:
            return UITextField.ViewMode.always.rawValue
        }
    }
}
#endif