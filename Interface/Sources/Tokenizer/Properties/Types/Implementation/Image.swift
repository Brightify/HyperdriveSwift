//
//  Image.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public enum Image: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    case named(String)
    case themed(String)

    public static let typeFactory = TypeFactory()

    public func requiresTheme(context: DataContext) -> Bool {
        switch self {
        case .named:
            return false
        case .themed:
            return true
        }
    }

    public func isOptional(context: SupportedPropertyTypeContext) -> Bool {
        switch self {
        case .named:
            return true
        case .themed(let themeName):
            return context.themed(color: themeName)?.isOptional(context: context) ?? true
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        let imageTypePrefix: String
        switch context.platform {
        case .iOS, .tvOS:
            imageTypePrefix = "UI"
        case .macOS:
            imageTypePrefix = "NS"
        }

        switch self {
        case .named(let name):
            return .constant("\(imageTypePrefix)Image(named: \"\(name)\", in: __resourceBundle, compatibleWith: nil)")
        case .themed(let name):
            return .constant("theme.images.\(name)")
        }
    }
    #endif

    #if HyperdriveRuntime
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .named(let name):
            #if canImport(UIKit)
            return UIImage(named: name)
            #else
            return NSImage(named: name)
            #endif
        case .themed(let name):
            guard let themedImage = context.themed(image: name) else { return nil }
            return themedImage.runtimeValue(context: context.child(for: themedImage))
        }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return name
    }
    #endif

    public static func materialize(from value: String) throws -> Image {
        if let themedName = ApplicationDescription.themedValueName(value: value) {
            return .themed(themedName)
        } else {
            return .named(value)
        }
    }
}

extension Image {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Image

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            switch platform {
            case .iOS, .tvOS:
                return RuntimeType(name: "UIImage", module: "UIKit")
            case .macOS:
                return RuntimeType(name: "NSImage", module: "AppKit")
            }
        }

        public var xsdType: XSDType {
            return .builtin(.string)
        }
    }
}

