//
//  XMLAttributeSerializable.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

public protocol XMLAttributeSerializable {
    func serialize() -> XMLSerializableAttribute
}
