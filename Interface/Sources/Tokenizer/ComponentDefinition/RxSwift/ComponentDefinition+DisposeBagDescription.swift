//
//  ComponentDefinition+DisposeBagDescription.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/01/2020.
//

import Foundation

extension ComponentDefinition {
    public struct DisposeBagDescription {
        public struct Item {
            public var name: String
            public var resetable: Bool

            public init(element: XMLElement) throws {
                name = element.name
                resetable = try element.value(ofAttribute: "resetable", defaultValue: true)
            }
        }

        public var items: [Item]

        public init(element: XMLElement?) throws {
            guard let element = element else {
                items = []
                return
            }

            items = try element.xmlChildren.map(Item.init(element:))
        }
    }
}
