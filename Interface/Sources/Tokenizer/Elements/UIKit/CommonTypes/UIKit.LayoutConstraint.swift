//
//  UIKit.LayoutConstraint.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 02/07/2019.
//

extension Module.UIKit {
    public enum LayoutConstraint: String, EnumPropertyType, AttributeSupportedPropertyType {
        public static let enumName = "NSLayoutConstraint.Attribute"
        public static let typeFactory = TypeFactory()

        case left
        case right
        case top
        case bottom
        case leading
        case trailing
        case width
        case height
        case centerX
        case centerY
        case lastBaseline
        case firstBaseline
        case leftMargin
        case rightMargin
        case topMargin
        case bottomMargin
        case leadingMargin
        case trailingMargin
        case centerXWithinMargins
        case centerYWithinMargins
        case notAnAttribute

        public final class TypeFactory: EnumTypeFactory {
            public typealias BuildType = LayoutConstraint

            public init() { }
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Module.UIKit.LayoutConstraint {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .left:
            return NSLayoutConstraint.Attribute.left.rawValue
        case .right:
            return NSLayoutConstraint.Attribute.right.rawValue
        case .top:
            return NSLayoutConstraint.Attribute.top.rawValue
        case .bottom:
            return NSLayoutConstraint.Attribute.bottom.rawValue
        case .leading:
            return NSLayoutConstraint.Attribute.leading.rawValue
        case .trailing:
            return NSLayoutConstraint.Attribute.trailing.rawValue
        case .width:
            return NSLayoutConstraint.Attribute.width.rawValue
        case .height:
            return NSLayoutConstraint.Attribute.height.rawValue
        case .centerX:
            return NSLayoutConstraint.Attribute.centerX.rawValue
        case .centerY:
            return NSLayoutConstraint.Attribute.centerY.rawValue
        case .lastBaseline:
            return NSLayoutConstraint.Attribute.lastBaseline.rawValue
        case .firstBaseline:
            return NSLayoutConstraint.Attribute.firstBaseline.rawValue
        case .leftMargin:
            return NSLayoutConstraint.Attribute.leftMargin.rawValue
        case .rightMargin:
            return NSLayoutConstraint.Attribute.rightMargin.rawValue
        case .topMargin:
            return NSLayoutConstraint.Attribute.topMargin.rawValue
        case .bottomMargin:
            return NSLayoutConstraint.Attribute.bottomMargin.rawValue
        case .leadingMargin:
            return NSLayoutConstraint.Attribute.leadingMargin.rawValue
        case .trailingMargin:
            return NSLayoutConstraint.Attribute.trailingMargin.rawValue
        case .centerXWithinMargins:
            return NSLayoutConstraint.Attribute.centerXWithinMargins.rawValue
        case .centerYWithinMargins:
            return NSLayoutConstraint.Attribute.centerYWithinMargins.rawValue
        case .notAnAttribute:
            return NSLayoutConstraint.Attribute.notAnAttribute.rawValue
        }
    }
}
#endif
