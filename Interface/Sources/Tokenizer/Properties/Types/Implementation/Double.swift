//
//  Double+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Double: TypedAttributeSupportedPropertyType, HasStaticTypeFactory {
    public static var typeFactory: TypeFactory {
        return TypeFactory()
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("\(self)")
    }
    #endif

    #if HyperdriveRuntime
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return generate(context: context)
    }
    #endif

    public static func materialize(from value: String) throws -> Double {
        guard let materialized = Double(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

extension Double {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Double

        public init() { }

        public var xsdType: XSDType {
            return .builtin(.decimal)
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "Double", module: "Swift")
        }
    }
}

extension Double: HasDefaultValue {
    public static let defaultValue: Double = 0
}
