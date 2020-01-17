//
//  ViewVisibility.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ViewVisibility: String, EnumPropertyType {
    public static let enumName = "Visibility"
    public static let typeFactory = EnumTypeFactory<ViewVisibility>()

    case visible
    case hidden
    case collapsed
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
