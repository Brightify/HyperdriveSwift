//
//  ProgressViewStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/04/2018.
//

public enum ProgressViewStyle: String, EnumPropertyType {
    public static let enumName = "UIProgressView.Style"
    public static let typeFactory = EnumTypeFactory<ProgressViewStyle>()

    case `default`
    case bar
}

#if canImport(UIKit)
import UIKit

extension ProgressViewStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .default:
            return UIProgressView.Style.default.rawValue
        case .bar:
            #if os(iOS)
            return UIProgressView.Style.bar.rawValue
            #else
            return nil
            #endif
        }
    }
}
#endif
