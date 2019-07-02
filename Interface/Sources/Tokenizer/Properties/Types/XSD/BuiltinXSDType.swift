//
//  BuiltinXSDType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

public enum BuiltinXSDType: String {
    case string
    case integer
    case decimal
    case boolean
    case token

    public var xsdName: String {
        return "xs:".appending(rawValue)
    }
}
