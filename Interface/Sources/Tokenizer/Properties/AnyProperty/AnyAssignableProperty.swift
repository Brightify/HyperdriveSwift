//
//  AnyAssignableProperty.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct AnyAssignableProperty: Property {
    public var name: String
    public let attributeName: String
    public var namespace: [PropertyContainer.Namespace]
    public let key: String
    public let swiftName: String

    public let anyValue: AnyPropertyValue
    public let anyDescription: PropertyDescription

    #if canImport(SwiftCodeGen)
    public func application(context: PropertyContext) -> Expression {
        return anyValue.generate(context: context.child(for: anyValue))
    }

    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)

        return .assignment(target: .member(target: .constant(namespacedTarget), name: swiftName), expression: application(context: context))
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: anyValue.dematerialize(context: context.child(for: anyValue)))
    }
    #endif

    #if HyperdriveRuntime
    public func apply(on object: AnyObject, context: PropertyContext) throws {
        let selector = Selector("set\(key.capitalizingFirstLetter()):")

        let target = try resolveTarget(for: object)

        guard target.responds(to: selector) else {
            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(key)` to set value `\(anyValue)`")
        }

        let resolvedValue = try anyValue.runtimeValue(context: context.child(for: anyValue))
        guard resolvedValue != nil || anyDescription.anyTypeFactory.isNullable else {
            throw LiveUIError(message: "!! Value `\(anyValue)` couldn't be resolved in runtime for key `\(key)`")
        }

        do {
            try catchException {
                _ = target.setValue(resolvedValue, forKey: key)
            }
        } catch {
            _ = target.perform(selector, with: resolvedValue)
        }

    }

    private func resolveTarget(for object: AnyObject) throws -> AnyObject {
        if namespace.isEmpty {
            return object
        } else {
            let keyPath = namespace.resolvedKeyPath
            guard let target = object.value(forKeyPath: keyPath) else {
                throw LiveUIError(message: "!! Object \(object) doesn't have keyPath \(keyPath) to resolve real target")
            }
            return target as AnyObject
        }
    }
    #endif
}
