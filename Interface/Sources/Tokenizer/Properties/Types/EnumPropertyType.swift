//
//  EnumPropertyType.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 09/03/2018.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public protocol HasEnumName {
    static var enumName: String { get }
}

public protocol EnumPropertyType: RawRepresentable, CaseIterable, HasEnumName, TypedSupportedType, HasStaticTypeFactory
    where RawValue == String {

}

public extension EnumPropertyType {
    var stateProperties: Set<String> {
        return []
    }

    #if canImport(SwiftCodeGen)
    func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("\(Self.enumName).\(rawValue)")
    }
    #endif
}

extension SupportedPropertyType where Self: RawRepresentable, Self.RawValue == String {
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return rawValue
    }
    #endif
}


open class EnumTypeFactory<BuildType: TypedSupportedType>: TypedSupportedTypeFactory, HasZeroArgumentInitializer where BuildType: HasEnumName & CaseIterable & RawRepresentable, BuildType.RawValue == String {

    open var xsdType: XSDType {
        let values = Set(BuildType.allCases.map { $0.rawValue })
        return .enumeration(EnumerationXSDType(name: BuildType.enumName, base: .string, values: values))
    }

    open func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        #warning("TODO: We should let the children decide the module here:")
        return RuntimeType(name: BuildType.enumName)
    }

    public required init() {

    }
}

extension EnumTypeFactory: TypedAttributeSupportedTypeFactory {
    public func typedMaterialize(from value: String) throws -> BuildType {
        guard let materialized = BuildType(rawValue: value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

