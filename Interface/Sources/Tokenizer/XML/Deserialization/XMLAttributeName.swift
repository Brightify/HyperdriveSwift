//
//  XMLAttributeName.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public protocol XMLAttributeName {
    init(from value: String) throws
}

extension Array: XMLAttributeDeserializable where Iterator.Element: XMLAttributeName {
    public static func deserialize(_ attribute: XMLAttribute) throws -> Array {
        let names = attribute.text.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter {
            !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        }

        return try names.map {
            try Iterator.Element(from: $0)
        }
    }
}
