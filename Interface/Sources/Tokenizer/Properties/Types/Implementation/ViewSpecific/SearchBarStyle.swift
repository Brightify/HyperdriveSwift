//
//  SearchBarStyle.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum SearchBarStyle: String, EnumPropertyType {
    public static let enumName = "UISearchBar.Style"
    public static let typeFactory = EnumTypeFactory<SearchBarStyle>()

    case `default`
    case minimal
    case prominent
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
