//
//  SmartDashesType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum SmartDashesType: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextSmartDashesType"
    public static let typeFactory = TypeFactory()

    case `default`
    case no
    case yes

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = SmartDashesType

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension SmartDashesType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        if #available(iOS 11.0, tvOS 110.0, *) {
            switch self {
            case .`default`:
                return UITextSmartDashesType.default.rawValue
            case .no:
                return UITextSmartDashesType.no.rawValue
            case .yes:
                return UITextSmartDashesType.yes.rawValue
            }
        } else {
            return nil
        }
    }
}
#endif
