//
//  XMLElement+valueOfAttribute.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

extension XMLElement {
    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String, defaultValue: @autoclosure () -> T) throws -> T {
        if let attr = self.attribute(by: attr) {
            return try T.deserialize(attr)
        } else {
            return defaultValue()
        }
    }
}
