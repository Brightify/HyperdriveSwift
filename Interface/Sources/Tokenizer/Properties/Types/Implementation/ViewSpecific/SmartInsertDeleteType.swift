//
//  SmartInsertDeleteType.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 15/08/2018.
//

import Foundation

public enum SmartInsertDeleteType: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextSmartInsertDeleteType"
    public static let typeFactory = TypeFactory()

    case `default`
    case no
    case yes

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = SmartInsertDeleteType

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension SmartInsertDeleteType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        if #available(iOS 11.0, tvOS 110.0, *) {
            switch self {
            case .`default`:
                return UITextSmartInsertDeleteType.default.rawValue
            case .no:
                return UITextSmartInsertDeleteType.no.rawValue
            case .yes:
                return UITextSmartInsertDeleteType.yes.rawValue
            }
        } else {
            return nil
        }
    }
}
#endif
