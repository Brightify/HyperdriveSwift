//
//  ActivityIndicatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ActivityIndicatorStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIActivityIndicatorView.Style"
    public static let typeFactory = TypeFactory()

    case whiteLarge
    case white
    case gray
}

extension ActivityIndicatorStyle {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = ActivityIndicatorStyle

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension ActivityIndicatorStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        #if os(tvOS)
        switch self {
        case .whiteLarge:
            return UIActivityIndicatorView.Style.whiteLarge.rawValue
        case .white:
            return UIActivityIndicatorView.Style.white.rawValue
        default:
            return nil
        }
        #else
            switch self {
            case .whiteLarge:
                return UIActivityIndicatorView.Style.whiteLarge.rawValue
            case .white:
                return UIActivityIndicatorView.Style.white.rawValue
            case .gray:
                return UIActivityIndicatorView.Style.gray.rawValue
            }
        #endif
    }
}
#endif
