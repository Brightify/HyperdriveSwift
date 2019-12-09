//
//  UIKitUIElementFactory.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

extension RuntimeModule {
    public func factory<T: Module.UIKit.View>(named name: String, for initializer: @escaping (UIElementDeserializationContext, UIElementFactory) throws -> T) -> UIElementFactory {
        return UIKitUIElementFactory(name: name, initializer: initializer)
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
