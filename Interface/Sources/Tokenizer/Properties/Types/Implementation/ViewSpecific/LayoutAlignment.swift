//
//  LayoutAlignment.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutAlignment: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIStackView.Alignment"
    public static let typeFactory = TypeFactory()

    case fill
    case firstBaseline
    case lastBaseline
    case leading
    case trailing
    case center
}

extension LayoutAlignment {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = LayoutAlignment

        public init() { }
    }
}

#if canImport(UIKit)
    import UIKit

    extension LayoutAlignment {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .center:
                return UIStackView.Alignment.center.rawValue
            case .fill:
                return UIStackView.Alignment.fill.rawValue
            case .firstBaseline:
                return UIStackView.Alignment.firstBaseline.rawValue
            case .lastBaseline:
                return UIStackView.Alignment.lastBaseline.rawValue
            case .leading:
                return UIStackView.Alignment.leading.rawValue
            case .trailing:
                return UIStackView.Alignment.trailing.rawValue
            }
        }
    }
#endif
