//
//  Font.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public enum Font: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    case system(weight: SystemFontWeight, size: Double)
    case named(String, size: Double)
    case themed(String)

    public static let typeFactory = TypeFactory()

    public var requiresTheme: Bool {
        switch self {
        case .system, .named:
            return false
        case .themed:
            return true
        }
    }

    public func isOptional(context: SupportedPropertyTypeContext) -> Bool {
        switch self {
        case .system:
            return false
        case .named:
            return true
        case .themed(let themeName):
            return context.themed(color: themeName)?.isOptional(context: context) ?? true
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .system(let weight, let size):
            return .constant("UIFont.systemFont(ofSize: \(size), weight: \(weight.name))")
        case .named(let name, let size):
            return .constant("UIFont(name: \"\(name)\", size: \(size))")
        case .themed(let name):
            return .constant("theme.fonts.\(name)")
        }
    }
    #endif
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .system(let weight, let size):
            return ":\(weight.rawValue)@\(size)"
        case .named(let name, let size):
            return "\(name)@\(size)"
        }
    }
    #endif

    public static func materialize(from value: String) throws -> Font {
        if let themedName = ApplicationDescription.themedValueName(value: value) {
            return .themed(themedName)
        } else {
            let tokens = Lexer.tokenize(input: value, keepWhitespace: true)
            return try FontParser(tokens: tokens).parseSingle()
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Font {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .system(let weight, let size):
            return UIFont.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight(rawValue: weight.value))
        case .named(let name, let size):
            return UIFont(name: name, size: CGFloat(size))
        case .themed(let name):
            guard let themedFont = context.themed(font: name) else { return nil }
            return themedFont.runtimeValue(context: context.child(for: themedFont))
        }
    }
}
#endif

extension Font {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Font

        public var xsdType: XSDType {
            return .builtin(.string)
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "UIFont", module: "UIKit")
        }
    }
}
