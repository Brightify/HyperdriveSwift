//
//  AppKit.LayoutConstraint.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 02/07/2019.
//

extension Module.AppKit {
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
        case notAnAttribute

        public final class TypeFactory: EnumTypeFactory {
            public typealias BuildType = LayoutConstraint

            public init() { }
        }
    }
}

#if HyperdriveRuntime && canImport(AppKit)
import AppKit

extension Module.AppKit.LayoutConstraint {
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
            if #available(OSX 10.11, *) {
                return NSLayoutConstraint.Attribute.firstBaseline.rawValue
            } else {
                return NSLayoutConstraint.Attribute.top.rawValue
            }
        case .notAnAttribute:
            return NSLayoutConstraint.Attribute.notAnAttribute.rawValue
        }
    }
}
#endif
