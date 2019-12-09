//
//  ComponentDefinitionContainer.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public protocol ComponentDefinitionContainer {
    var componentTypes: [String] { get }

    var componentDefinitions: [ComponentDefinition] { get }
}
