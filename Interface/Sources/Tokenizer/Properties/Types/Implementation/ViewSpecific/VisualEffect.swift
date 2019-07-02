//
//  VisualEffect.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public enum VisualEffect: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    public static var typeFactory = TypeFactory()
    public var factory: SupportedTypeFactory {
        return PreferredSize.typeFactory
    }

    case blur(BlurEffect)
    case vibrancy(BlurEffect)

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .blur(let effect):
            return .constant("UIBlurEffect(style: .\(effect.rawValue))")
        case .vibrancy(let effect):
            return .constant("UIVibrancyEffect(blurEffect: .\(effect.rawValue))")
        }
    }
    #endif
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .blur(let effect):
            return "blur:\(effect.rawValue)"
        case .vibrancy(let effect):
            return "vibrancy:\(effect.rawValue)"
        }
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .blur(let effect):
            return effect.runtimeValue
        case .vibrancy(let effect):
            guard let blurEffect = effect.runtimeValue as? UIBlurEffect else { return nil }
            return UIVibrancyEffect(blurEffect: blurEffect)
        }
    }
    #endif

    public static func materialize(from value: String) throws -> VisualEffect {
        let parts = value.components(separatedBy: ":")
        guard parts.count == 2 && (parts.first == "blur" || parts.first == "vibrancy") else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        guard let effect = BlurEffect(rawValue: parts[1]) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return parts.first == "blur" ? .blur(effect) : .vibrancy(effect)
    }

    static var allValues: [VisualEffect] = BlurEffect.allCases.map(VisualEffect.blur) + BlurEffect.allCases.map(VisualEffect.vibrancy)

    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = VisualEffect

        public var xsdType: XSDType {
            let values = Set(VisualEffect.allValues.map { masterEffect -> String in
                switch masterEffect {
                case .blur(let effect):
                    return ":blur:\(effect.rawValue)"
                case .vibrancy(let effect):
                    return ":vibrancy:\(effect.rawValue)"
                }
            })

            return .enumeration(EnumerationXSDType(name: "UIVisualEffect", base: .string, values: values))
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            switch platform {
            case .iOS, .tvOS:
                return RuntimeType(name: "UIVisualEffect", module: "UIKit")
            case .macOS:
                return RuntimeType.unsupported
            }
        }
    }
}

public enum BlurEffect: String, CaseIterable {
    case extraLight
    case light
    case dark
    case prominent
    case regular
}

#if canImport(UIKit)
import UIKit

extension BlurEffect {
    public var runtimeValue: Any? {
        switch self {
        case .extraLight:
            return UIBlurEffect(style: .extraLight)
        case .light:
            return UIBlurEffect(style: .light)
        case .dark:
            return UIBlurEffect(style: .dark)
        case .prominent:
            if #available(iOS 10.0, tvOS 10.0, *) {
                return UIBlurEffect(style: .prominent)
            } else {
                // FIXME check default values
                return UIBlurEffect(style: .light)
            }
        case .regular:
            if #available(iOS 10.0, tvOS 10.0, *) {
                return UIBlurEffect(style: .regular)
            } else {
                return UIBlurEffect(style: .light)
            }
        }
    }
}
#endif
