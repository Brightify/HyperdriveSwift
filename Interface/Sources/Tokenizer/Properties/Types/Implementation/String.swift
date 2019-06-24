//
//  String.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 16/06/2019.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension String: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    public static var typeFactory: TypeFactory {
        return TypeFactory()
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant(#""\#(self)""#)
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return self
    }
    #endif

    public static func materialize(from value: String) throws -> String {
        return value
    }
}

extension String {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = String

        public var xsdType: XSDType {
            return .builtin(.string)
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "String", module: "Swift")
        }
    }
}

extension String: HasDefaultValue {
    public static let defaultValue: String = ""
}
