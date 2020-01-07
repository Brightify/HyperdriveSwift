//
//  RuntimePlatform.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

public enum RuntimePlatform: CustomStringConvertible, CaseIterable {
    case iOS
    case macOS
    case tvOS

    public static var current: RuntimePlatform {
        #if os(iOS)
        return .iOS
        #elseif os(OSX)
        return .macOS
        #elseif os(tvOS)
        return .tvOS
        #else
        #error("Unsupported platform.")
        #endif
    }

    public var description: String {
        switch self {
        case .iOS:
            return "Support for iOS views."
        case .tvOS:
            return "Support for tvOS views."
        case .macOS:
            return "Support for macOS views."
        }
    }

    public var supportedTypes: [SupportedTypeFactory] {
        let commonTypes: [SupportedTypeFactory] = [
            TransformedText.typeFactory,
            Double.typeFactory,
            Int.typeFactory,
            Float.typeFactory,
            Bool.typeFactory,
            Point.typeFactory,
        ]

        let platformTypes: [SupportedTypeFactory]
        switch self {
        case .iOS, .tvOS:
            platformTypes = [
                UIColorPropertyType.typeFactory,
                CGColorPropertyType.typeFactory,
            ]
        case .macOS:
            platformTypes = [
                UIColorPropertyType.typeFactory,
                CGColorPropertyType.typeFactory,
            ]
        }

        return platformTypes + commonTypes
    }
}
