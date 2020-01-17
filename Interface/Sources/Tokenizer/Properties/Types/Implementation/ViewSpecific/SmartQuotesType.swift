//
//  SmartQuotesType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum SmartQuotesType: String, EnumPropertyType {
    public static let enumName = "UITextSmartQuotesType"
    public static let typeFactory = EnumTypeFactory<SmartQuotesType>()

    case `default`
    case no
    case yes
}

#if canImport(UIKit)
import UIKit

extension SmartQuotesType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        if #available(iOS 11.0, tvOS 110.0, *) {
            switch self {
            case .`default`:
                return UITextSmartQuotesType.default.rawValue
            case .no:
                return UITextSmartQuotesType.no.rawValue
            case .yes:
                return UITextSmartQuotesType.yes.rawValue
            }
        } else {
            return nil
        }
    }
}
#endif
