//
//  SearchBarStyle.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum SearchBarStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UISearchBar.Style"
    public static let typeFactory = TypeFactory()

    case `default`
    case minimal
    case prominent
}

extension SearchBarStyle {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = SearchBarStyle

        public init() { }
    }
}

#if canImport(UIKit)
    import UIKit

    extension SearchBarStyle {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .`default`:
                return UISearchBar.Style.default.rawValue
            case .minimal:
                return UISearchBar.Style.minimal.rawValue
            case .prominent:
                return UISearchBar.Style.prominent.rawValue
            }
        }
    }
#endif
