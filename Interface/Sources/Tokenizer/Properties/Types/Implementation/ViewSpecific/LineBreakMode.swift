//
//  LineBreakMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum LineBreakMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSLineBreakMode"
    public static let typeFactory = TypeFactory()

    case byWordWrapping
    case byCharWrapping
    case byClipping
    case byTruncatingHead
    case byTruncatingTail
    case byTruncatingMiddle

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = LineBreakMode

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension LineBreakMode {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .byWordWrapping:
            return NSLineBreakMode.byWordWrapping.rawValue
        case .byCharWrapping:
            return NSLineBreakMode.byCharWrapping.rawValue
        case .byClipping:
            return NSLineBreakMode.byClipping.rawValue
        case .byTruncatingHead:
            return NSLineBreakMode.byTruncatingHead.rawValue
        case .byTruncatingTail:
            return NSLineBreakMode.byTruncatingTail.rawValue
        case .byTruncatingMiddle:
            return NSLineBreakMode.byTruncatingMiddle.rawValue
        }
    }
}
#endif