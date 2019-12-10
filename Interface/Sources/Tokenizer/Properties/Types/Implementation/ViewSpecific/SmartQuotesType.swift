//
//  SmartQuotesType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum SmartQuotesType: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextSmartQuotesType"
    public static let typeFactory = TypeFactory()

    case `default`
    case no
    case yes

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = SmartQuotesType

        public init() { }
    }
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