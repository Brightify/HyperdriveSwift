//
//  ScrollViewIndicatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ScrollViewIndicatorStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIScrollView.IndicatorStyle"
    public static let typeFactory = TypeFactory()

    case `default`
    case black
    case white

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = ScrollViewIndicatorStyle

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension ScrollViewIndicatorStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .default:
            return UIScrollView.IndicatorStyle.default.rawValue
        case .black:
            return UIScrollView.IndicatorStyle.black.rawValue
        case .white:
            return UIScrollView.IndicatorStyle.white.rawValue
        }
    }
}
#endif
