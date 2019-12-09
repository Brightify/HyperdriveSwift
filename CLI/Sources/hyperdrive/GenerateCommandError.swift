//
//  GenerateCommandError.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public enum GenerateCommandError: Error, LocalizedError {
    case inputPathInvalid
    case ouputFileInvalid
    case applicationDescriptionFileInvalid
    case XCodeProjectPathInvalid
    case cannotReadXCodeProj(Error)
    case invalidType(String)
    case tokenizationError(path: String, error: Error)
    case invalidSwiftVersion
    case themedItemNotFound(theme: String, item: String)
    case invalidAccessModifier
    case platformNotSpecified

    public var localizedDescription: String {
        switch self {
        case .inputPathInvalid:
            return "Input path is invalid."
        case .ouputFileInvalid:
            return "Output file path is invalid."
        case .applicationDescriptionFileInvalid:
            return "Application description file path is invalid."
        case .XCodeProjectPathInvalid:
            return "xcodeproj path is invalid."
        case .cannotReadXCodeProj(let error):
            return "Cannot read xcodeproj." + error.localizedDescription
        case .invalidType(let path):
            return "Invalid Component type at path: \(path) - do not use keywords.";
        case .tokenizationError(let path, let error):
            return "Tokenization error in file: \(path), error: \(error)"
        case .invalidSwiftVersion:
            return "Invalid Swift version"
        case .themedItemNotFound(let theme, let item):
            return "Missing item `\(item) in theme \(theme)."
        case .invalidAccessModifier:
            return "Invalid access modifier"
        case .platformNotSpecified:
            return "Platform not specified."
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}

