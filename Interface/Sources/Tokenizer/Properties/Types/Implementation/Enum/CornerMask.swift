//
//  CornerMask.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 08/01/2020.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct CornerMask: OptionSet, Hashable, TypedSupportedType, HasStaticTypeFactory {
    public typealias TypeFactory = CornerMask.CornerMaskTypeFactory
    public static let typeFactory = TypeFactory()

    public static let bottomRight = CornerMask(rawValue: 1 << 0)
    public static let topRight = CornerMask(rawValue: 1 << 1)
    public static let bottomLeft = CornerMask(rawValue: 1 << 2)
    public static let topLeft = CornerMask(rawValue: 1 << 3)

    public static let none = CornerMask(rawValue: 0)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        let map = [
            .bottomRight: "CACornerMask.layerMaxXMaxYCorner",
            .topRight: "CACornerMask.layerMaxXMinYCorner",
            .bottomLeft: "CACornerMask.layerMinXMaxYCorner",
            .topLeft: "CACornerMask.layerMinXMinYCorner",
        ] as [CornerMask: String]

        let values = map.compactMap { key, value in
            contains(key) ? value : nil
        }

        return .constant("[\(values.joined(separator: ", "))]")
    }
    #endif
}

extension CornerMask {
    public final class CornerMaskTypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = CornerMask

        public var xsdType: XSDType {
            return .builtin(.string)
        }

        public init() { }

        public func typedMaterialize(from value: String) throws -> CornerMask {
            return try value.replacingOccurrences(of: " ", with: "").split(separator: ",").map { value -> CornerMask in
                switch value {
                case "bottomRight":
                    return .bottomRight
                case "topRight":
                    return .topRight
                case "bottomLeft":
                    return .bottomLeft
                case "topLeft":
                    return .topLeft
                default:
                    throw TokenizationError(message: "Invalid value for type CACornerMask: \(value)")
                }
            }.reduce(CornerMask.none) { $0.union($1) }
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "CACornerMask", module: "CoreAnimation")
        }
    }
}

#if canImport(UIKit)
import UIKit

extension CornerMask {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        let map = [
            .bottomRight: CACornerMask.layerMaxXMaxYCorner,
            .topRight: CACornerMask.layerMaxXMinYCorner,
            .bottomLeft: CACornerMask.layerMinXMaxYCorner,
            .topLeft: CACornerMask.layerMinXMinYCorner,
        ] as [CornerMask: CACornerMask]

        return map.compactMap { key, value in
            contains(key) ? value : nil
        }.reduce([] as CACornerMask) { $0.union($1) }
    }
}
#endif

