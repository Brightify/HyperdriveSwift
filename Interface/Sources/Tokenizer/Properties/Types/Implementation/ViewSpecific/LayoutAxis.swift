//
//  LayoutAxis.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

public enum LayoutAxis: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSLayoutConstraint.Axis"
    public static let typeFactory = TypeFactory()

    case vertical
    case horizontal
}

extension LayoutAxis {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = LayoutAxis

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension LayoutAxis {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .vertical:
            return NSLayoutConstraint.Axis.vertical.rawValue
        case .horizontal:
            return NSLayoutConstraint.Axis.horizontal.rawValue
        }
    }
}
#endif
