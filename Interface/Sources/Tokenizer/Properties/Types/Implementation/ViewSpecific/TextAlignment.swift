//
//  TextAlignment.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum TextAlignment: String, EnumPropertyType {
    public static let enumName = "NSTextAlignment"
    public static let typeFactory = EnumTypeFactory<TextAlignment>()

    case left
    case right
    case center
    case justified
    case natural
}

#if HyperdriveRuntime
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension TextAlignment {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .center:
            return NSTextAlignment.center.rawValue
        case .left:
            return NSTextAlignment.left.rawValue
        case .right:
            return NSTextAlignment.right.rawValue
        case .justified:
            return NSTextAlignment.justified.rawValue
        case .natural:
            return NSTextAlignment.natural.rawValue
        }
    }
}
#endif
