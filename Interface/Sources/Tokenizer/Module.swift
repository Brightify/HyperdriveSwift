//
//  Module.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public struct Module {
    
}

public protocol UIElementFactory: AnyObject {
    var elementName: String { get }

    #warning("REMOVEME Rewrite handling imports")
    var parentModuleImport: String { get }

    var availableProperties: [PropertyDescription] { get }

    var isContainer: Bool { get }

    func create(context: UIElementDeserializationContext) throws -> UIElement

    func runtimeType() throws -> RuntimeType
}

public protocol RuntimeModule {
    var supportedPlatforms: Set<RuntimePlatform> { get }

    var referenceFactory: ComponentReferenceFactory? { get }

    func elements(for platform: RuntimePlatform) -> [UIElementFactory]
}

extension RuntimeModule {
    public func factory<T: Module.UIKit.View>(named name: String, for initializer: @escaping (UIElementDeserializationContext, UIElementFactory) throws -> T) -> UIElementFactory {
        return UIKitUIElementFactory(name: name, initializer: initializer)
    }

    public func factory<T: Module.AppKit.View>(named name: String, for initializer: @escaping (UIElementDeserializationContext, UIElementFactory) throws -> T) -> UIElementFactory {
        return AppKitUIElementFactory(name: name, initializer: initializer)
    }

    public var referenceFactory: ComponentReferenceFactory? {
        return nil
    }
}

private class UIKitUIElementFactory<VIEW: Module.UIKit.View>: UIElementFactory {
    let elementName: String
    let initializer: (UIElementDeserializationContext, UIElementFactory) throws -> VIEW

    var availableProperties: [PropertyDescription] {
        return VIEW.availableProperties
    }

    var parentModuleImport: String {
        return VIEW.parentModuleImport
    }

    var isContainer: Bool {
        return VIEW.self is UIContainer.Type
    }

    init(name: String, initializer: @escaping (UIElementDeserializationContext, UIElementFactory) throws -> VIEW) {
        elementName = name
        self.initializer = initializer
    }

    func create(context: UIElementDeserializationContext) throws -> UIElement {
        return try initializer(context, self)
    }

    func runtimeType() throws -> RuntimeType {
        return RuntimeType(name: try VIEW.runtimeType())
    }
}

// FIXME: Identical, maybe a common protocol?
private class AppKitUIElementFactory<VIEW: Module.AppKit.View>: UIElementFactory {
    let elementName: String
    let initializer: (UIElementDeserializationContext, UIElementFactory) throws -> VIEW

    var availableProperties: [PropertyDescription] {
        return VIEW.availableProperties
    }

    var parentModuleImport: String {
        return VIEW.parentModuleImport
    }

    var isContainer: Bool {
        return VIEW.self is UIContainer.Type
    }

    init(name: String, initializer: @escaping (UIElementDeserializationContext, UIElementFactory) throws -> VIEW) {
        elementName = name
        self.initializer = initializer
    }

    func create(context: UIElementDeserializationContext) throws -> UIElement {
        return try initializer(context, self)
    }

    func runtimeType() throws -> RuntimeType {
        return RuntimeType(name: try VIEW.runtimeType())
    }
}
