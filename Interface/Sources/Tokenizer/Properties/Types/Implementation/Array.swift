//
//  Array.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Array: TypedSupportedType & SupportedPropertyType & HasStaticTypeFactory where Element: SupportedPropertyType & HasStaticTypeFactory {
    public static var typeFactory: TypeFactory {
        return TypeFactory()
    }
    public var typedFactory: Array<Element>.TypeFactory {
        return TypeFactory()
    }

    public func requiresTheme(context: DataContext) -> Bool {
        return contains(where: { $0.requiresTheme(context: context) })
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .arrayLiteral(items: map { $0.generate(context: context.child(for: $0)) })
    }
    #endif

    #if !GeneratingInterface
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        return try map { try $0.runtimeValue(context: context.child(for: $0)) }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return map { $0.dematerialize(context: context.child(for: $0)) }.joined(separator: ";")
    }
    #endif

    public final class TypeFactory: TypedSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = [Element]

        public var xsdType: XSDType {
            return .builtin(.string)
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            let elementRuntimeType = Element.typeFactory.runtimeType(for: platform)
            return RuntimeType(name: "[\(elementRuntimeType)]", modules: ["Swift"] + elementRuntimeType.modules)
        }
    }
}

extension Array: AttributeSupportedPropertyType where Element: TypedAttributeSupportedPropertyType & HasStaticTypeFactory {
    public static func materialize(from value: String) throws -> Array<Element> {
        // removing spaces might be problematic, hopefully no sane `SupportedPropertyType` uses space as part of tokenizing
        // comma separation might be problematic as some types might use it inside of themselves, e.g. a point (x: 10, y: 12)
        return try value.replacingOccurrences(of: " ", with: "").components(separatedBy: ";").map { try Element.materialize(from: $0) }
    }
}

//extension Array.TypeFactory: AttributeSupportedTypeFactory where Element: TypedAttributeSupportedPropertyType & HasStaticTypeFactory, Element.TypeFactory: AttributeSupportedTypeFactory {
//
//}
//
//extension Array.TypeFactory: TypedAttributeSupportedTypeFactory where Element: TypedAttributeSupportedPropertyType & HasStaticTypeFactory, Element.TypeFactory: TypedAttributeSupportedTypeFactory { }
