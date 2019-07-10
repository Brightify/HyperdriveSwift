//
//  AnySupportedTypeFactory.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct AnySupportedTypeFactory: SupportedTypeFactory {
    public let isNullable: Bool
    public let xsdType: XSDType
    private let resolveRuntimeType: (RuntimePlatform) -> RuntimeType
    #if canImport(SwiftCodeGen)
    private let generateStateAccess: (String) -> Expression
    #endif

    #if canImport(SwiftCodeGen)
    public init(isNullable: Bool = false, xsdType: XSDType, resolveRuntimeType: @escaping (RuntimePlatform) -> RuntimeType, generateStateAccess: @escaping (String) -> Expression) {
        self.isNullable = isNullable
        self.xsdType = xsdType
        self.resolveRuntimeType = resolveRuntimeType
        self.generateStateAccess = generateStateAccess
    }
    #else
    public init(isNullable: Bool = false, xsdType: XSDType, resolveRuntimeType: @escaping (RuntimePlatform) -> RuntimeType) {
        self.isNullable = isNullable
        self.xsdType = xsdType
        self.resolveRuntimeType = resolveRuntimeType
    }
    #endif

    public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return resolveRuntimeType(platform)
    }

    #if canImport(SwiftCodeGen)
    public func generate(stateName: String) -> Expression {
        return generateStateAccess(stateName)
    }
    #endif
}
