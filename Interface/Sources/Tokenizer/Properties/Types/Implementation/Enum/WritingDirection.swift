//
//  WritingDirection.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation

public enum WritingDirection: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSWritingDirection"
    public static let typeFactory = TypeFactory()

    case natural
    case leftToRight
    case rightToLeft

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = WritingDirection

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension WritingDirection {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .natural:
            return NSWritingDirection.natural.rawValue
        case .leftToRight:
            return NSWritingDirection.leftToRight.rawValue
        case .rightToLeft:
            return NSWritingDirection.rightToLeft.rawValue
        }
    }
}
#endif
