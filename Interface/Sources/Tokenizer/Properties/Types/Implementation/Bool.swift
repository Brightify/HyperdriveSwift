//
//  Bool+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Bool: TypedSupportedType, HasStaticTypeFactory {
    public static var typeFactory: TypeFactory {
        return TypeFactory()
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant(self ? "true" : "false")
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return generate(context: context)
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif
}

extension Bool {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Bool

        public var xsdType: XSDType {
            return .builtin(.boolean)
        }

        public init() { }

        public func typedMaterialize(from value: String) throws -> Bool {
            guard let materialized = Bool(value) else {
                throw PropertyMaterializationError.unknownValue(value)
            }
            return materialized
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "Bool")
        }
    }
}

extension Bool: HasDefaultValue {
    public static let defaultValue: Bool = false
}
