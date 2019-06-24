//
//  LayoutDistribution.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutDistribution: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIStackView.Distribution"
    public static let typeFactory = TypeFactory()

    case fill
    case fillEqually
    case fillProportionally
    case equalCentering
    case equalSpacing
}

extension LayoutDistribution {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = LayoutDistribution

        public init() { }
    }
}

#if canImport(UIKit)
    import UIKit

    extension LayoutDistribution {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .equalCentering:
                return UIStackView.Distribution.equalCentering.rawValue
            case .equalSpacing:
                return UIStackView.Distribution.equalSpacing.rawValue
            case .fill:
                return UIStackView.Distribution.fill.rawValue
            case .fillEqually:
                return UIStackView.Distribution.fillEqually.rawValue
            case .fillProportionally:
                return UIStackView.Distribution.fillProportionally.rawValue
            }
        }
    }
#endif
