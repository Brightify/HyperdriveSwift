//
//  RuntimePlatform+ConvertibleFromString.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Tokenizer
import SwiftCLI

extension RuntimePlatform: ConvertibleFromString {
    public static func convert(from: String) -> RuntimePlatform? {
        switch from.lowercased() {
        case "ios":
            return .iOS
        case "tvos":
            return .tvOS
        case "macos":
            return .macOS
        default:
            return nil
        }
    }

    public static func from(platformName: String) -> RuntimePlatform? {
        switch platformName.lowercased() {
        case "iphoneos", "iphonesimulator":
            return .iOS
        case "appletvos", "appletvsimulator":
            return .tvOS
        case "macosx":
            return .macOS
        default:
            return nil
        }
    }
}
