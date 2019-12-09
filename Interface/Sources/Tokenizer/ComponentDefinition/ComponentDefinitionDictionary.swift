//
//  ComponentDefinitionDictionary.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public struct ComponentDefinitionDictionary {
    public typealias ComponentType = String
    public typealias ComponentPath = String

    public private(set) var definitionsByType: [ComponentType: ComponentDefinition] = [:]
    public private(set) var definitionsByPath: [ComponentPath: [ComponentDefinition]] = [:]

    public subscript(path path: String) -> [ComponentDefinition] {
        get {
            return definitionsByPath[path, default: []]
        }
        set {
            for definition in definitionsByPath[path, default: []] {
                self[type: definition.type] = nil
            }

            for definition in newValue {
                self[type: definition.type] = definition
            }

            definitionsByPath[path] = newValue
        }
    }

    public private(set) subscript(type type: String) -> ComponentDefinition? {
        get {
            return definitionsByType[type]
        }
        set {
            definitionsByType[type] = newValue
        }
    }
}
