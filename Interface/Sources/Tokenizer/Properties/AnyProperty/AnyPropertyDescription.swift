//
//  AnyPropertyDescription.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

import Foundation

public struct AnyPropertyDescription: PropertyDescription {
    public let name: String
    public let namespace: [PropertyContainer.Namespace]
    public let anyDefaultValue: SupportedPropertyType
    public let anyTypeFactory: SupportedTypeFactory
}
