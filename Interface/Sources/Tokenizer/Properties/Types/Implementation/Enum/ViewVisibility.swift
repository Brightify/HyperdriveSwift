//
//  ViewVisibility.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ViewVisibility: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "Visibility"
    public static let typeFactory = TypeFactory()

    case visible
    case hidden
    case collapsed

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = ViewVisibility

        public init() { }
    }
}

#if HyperdriveRuntime
import HyperdriveInterface

extension ViewVisibility {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .visible:
            return Visibility.visible.rawValue
        case .collapsed:
            return Visibility.collapsed.rawValue
        case .hidden:
            return Visibility.hidden.rawValue
        }
    }
}
#endif
