//
//  AutocapitalizationType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 15/08/2018.
//

public enum AutocapitalizationType: String, EnumPropertyType {
    public static let enumName = "UITextAutocapitalizationType"
    public static let typeFactory = EnumTypeFactory<AutocapitalizationType>()

    case none
    case words
    case sentences
    case allCharacters
}

#if canImport(UIKit)
import UIKit

extension AutocapitalizationType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .none:
            return UITextAutocapitalizationType.none.rawValue
        case .words:
            return UITextAutocapitalizationType.words.rawValue
        case .sentences:
            return UITextAutocapitalizationType.sentences.rawValue
        case .allCharacters:
            return UITextAutocapitalizationType.allCharacters.rawValue
        }
    }
}
#endif
