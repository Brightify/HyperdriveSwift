//
//  UIElementFactory.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public protocol UIElementFactory: AnyObject {
    var elementName: String { get }

    #warning("REMOVEME Rewrite handling imports")
    var parentModuleImport: String { get }

    var availableProperties: [PropertyDescription] { get }

    var isContainer: Bool { get }

    func create(context: UIElementDeserializationContext) throws -> UIElement

    func runtimeType() throws -> RuntimeType
}
