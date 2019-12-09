//
//  ComponentDefinition+StateDescription.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

extension ComponentDefinition {
    public struct StateDescription {
        public struct Item {
            public var name: String
            public var type: String
            public var defaultValue: String?
            public var isOptional: Bool
            public var handler: String?

            public init(element: XMLElement) throws {
                name = element.name

                guard let type = element.attribute(by: "type")?.text else {
                    throw TokenizationError(message: "State item is required to have a `type` attribute!")
                }
                self.type = type

                defaultValue = element.attribute(by: "default")?.text
                isOptional = element.attribute(by: "optional")?.text.lowercased() == "true"

                handler = element.attribute(by: "receiver")?.text
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
