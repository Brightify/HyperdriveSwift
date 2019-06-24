//
//  RuntimePlatform.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public enum RuntimePlatform: CustomStringConvertible, CaseIterable {
    case iOS
    //    case macOS
    case tvOS

    public var description: String {
        switch self {
        case .iOS:
            return "Support for iOS views."
        case .tvOS:
            return "Support for tvOS views."
        }
    }

    public var supportedTypes: [SupportedTypeFactory] {
        let commonTypes: [SupportedTypeFactory] = [
            TransformedText.typeFactory,
            Double.typeFactory,
            Int.typeFactory,
            Float.typeFactory,
            Bool.typeFactory,

        ]

        let platformTypes: [SupportedTypeFactory]
        switch self {
        case .iOS, .tvOS:
            platformTypes = [
                UIColorPropertyType.typeFactory,
                CGColorPropertyType.typeFactory,
            ]
        }

        return platformTypes + commonTypes
    }
}
