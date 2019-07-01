//
//  Property.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

/**
 * Base protocol for UI element properties.
 */
public protocol Property {
    var name: String { get set }
    
    var attributeName: String { get }
    
    var namespace: [PropertyContainer.Namespace] { get set }

    var anyValue: AnyPropertyValue { get }

    var anyDescription: PropertyDescription { get }

    #if canImport(SwiftCodeGen)
    func application(context: PropertyContext) -> Expression

    func application(on target: String, context: PropertyContext) -> Statement
    #endif

    #if SanAndreas
    func dematerialize(context: PropertyContext) -> XMLSerializableAttribute
    #endif
    
    #if canImport(UIKit)
    func apply(on object: AnyObject, context: PropertyContext) throws -> Void
    #endif
}

public protocol TypedProperty: Property {
    associatedtype ValueType = FactoryType.BuildType
    associatedtype FactoryType
    associatedtype PropertyDescriptionType: TypedPropertyDescription where PropertyDescriptionType.FactoryType == FactoryType

    var value: PropertyValue<FactoryType> { get set }

    var description: PropertyDescriptionType { get }
}

extension Property where Self: TypedProperty {
    public var anyValue: AnyPropertyValue {
        return value.typeErased()
    }

    public var anyDescription: PropertyDescription {
        return description
    }
}

public enum PropertyValue<T: TypedSupportedTypeFactory> {
    case value(T.BuildType)
    case state(String, factory: T)

    public var value: T.BuildType? {
        switch self {
        case .value(let value):
            return value
        case .state:
            return nil
        }
    }

    public var requiresTheme: Bool {
        switch self {
        case .value(let value):
            return value.requiresTheme
        case .state:
            return false
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return typeErased().generate(context: context)
    }
    #endif

    public func typeErased() -> AnyPropertyValue {
        switch self {
        case .value(let value):
            return .value(value)
        case .state(let name, let factory):
            return .state(name, factory: factory)
        }
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        switch self {
        case .value(let value):
            return try value.runtimeValue(context: context.child(for: value))
        case .state(let name, _):
            return try context.resolveStateProperty(named: name)
        }
    }
    #endif
}


public enum AnyPropertyValue {
    case value(SupportedPropertyType)
    case state(String, factory: SupportedTypeFactory)

    public var requiresTheme: Bool {
        switch self {
        case .value(let value):
            return value.requiresTheme
        case .state:
            return false
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .value(let value):
            return value.generate(context: context)
        case .state(let name, let factory):
            return factory.generate(stateName: name)
        }
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        switch self {
        case .value(let value):
            return try value.runtimeValue(context: context.child(for: value))
        case .state(let name, _):
            return try context.resolveStateProperty(named: name)
        }
    }
    #endif
}
