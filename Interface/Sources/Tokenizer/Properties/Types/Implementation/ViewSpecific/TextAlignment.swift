//
//  TextAlignment.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum TextAlignment: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSTextAlignment"
    public static let typeFactory = TypeFactory()

    case left
    case right
    case center
    case justified
    case natural
}

extension TextAlignment {
    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = TextAlignment

        public init() { }
    }
}

#if canImport(UIKit)
    import UIKit

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
