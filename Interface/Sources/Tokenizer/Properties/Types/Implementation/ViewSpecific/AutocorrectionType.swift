//
//  AutocorrectionType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum AutocorrectionType: String, EnumPropertyType {
    public static let enumName = "UITextAutocorrectionType"
    public static let typeFactory = EnumTypeFactory<AutocorrectionType>()

    case `default`
    case no
    case yes
}

#if canImport(UIKit)
import UIKit

extension AutocorrectionType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .`default`:
            return UITextAutocorrectionType.default.rawValue
        case .no:
            return UITextAutocorrectionType.no.rawValue
        case .yes:
            return UITextAutocorrectionType.yes.rawValue
        }
    }
}
#endif
