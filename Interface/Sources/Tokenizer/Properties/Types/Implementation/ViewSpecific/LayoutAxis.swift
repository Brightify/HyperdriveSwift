//
//  LayoutAxis.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

public enum LayoutAxis: String, EnumPropertyType {
    public static let enumName = "NSLayoutConstraint.Axis"
    public static let typeFactory = EnumTypeFactory<LayoutAxis>()

    case vertical
    case horizontal
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
