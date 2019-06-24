//
//  Float+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Float: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    public static var typeFactory: TypeFactory {
        return TypeFactory()
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("\(self)")
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return generate(context: context)
    }
    #endif

    public static func materialize(from value: String) throws -> Float {
        guard let materialized = Float(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

extension Float {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Float

        public var xsdType: XSDType {
            return .builtin(.decimal)
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "Float")
        }
    }
}
