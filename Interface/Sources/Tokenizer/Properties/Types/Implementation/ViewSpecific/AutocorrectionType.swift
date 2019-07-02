//
//  AutocorrectionType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum AutocorrectionType: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextAutocorrectionType"
    public static let typeFactory = TypeFactory()

    case `default`
    case no
    case yes

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = AutocorrectionType

        public init() { }
    }
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
