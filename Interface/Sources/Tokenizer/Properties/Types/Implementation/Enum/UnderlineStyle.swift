//
//  UnderlineStyle.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/05/2018.
//

#if canImport(UIKit)
import UIKit
#endif

public enum UnderlineStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSUnderlineStyle"
    public static let typeFactory = TypeFactory()

    case none
    case single
    case thick
    case double
    case patternDot
    case patternDash
    case patternDashDot
    case patternDashDotDot
    case byWord

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = UnderlineStyle

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension UnderlineStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .none:
            return ([] as NSUnderlineStyle).rawValue
        case .single:
            return NSUnderlineStyle.single.rawValue
        case .thick:
            return NSUnderlineStyle.thick.rawValue
        case .double:
            return NSUnderlineStyle.double.rawValue
        case .patternDot:
            return NSUnderlineStyle.patternDot.rawValue
        case .patternDash:
            return NSUnderlineStyle.patternDash.rawValue
        case .patternDashDot:
            return NSUnderlineStyle.patternDashDot.rawValue
        case .patternDashDotDot:
            return NSUnderlineStyle.patternDashDotDot.rawValue
        case .byWord:
            return NSUnderlineStyle.byWord.rawValue
        }
    }
}
#endif