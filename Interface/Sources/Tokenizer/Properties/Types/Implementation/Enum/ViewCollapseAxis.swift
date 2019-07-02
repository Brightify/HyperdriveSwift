//
//  ViewCollapseAxis.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 09/08/2018.
//

import Foundation

public enum ViewCollapseAxis: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "CollapseAxis"
    public static let typeFactory = TypeFactory()

    case horizontal
    case vertical
    case both

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = ViewCollapseAxis

        public init() { }
    }
}

#if canImport(UIKit)
import HyperdriveInterface

extension ViewCollapseAxis {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .both:
            return CollapseAxis.both.rawValue
        case .horizontal:
            return CollapseAxis.horizontal.rawValue
        case .vertical:
            return CollapseAxis.vertical.rawValue
        }
    }
}
#endif
