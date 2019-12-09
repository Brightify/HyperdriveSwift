//
//  GeneratorConfiguration.swift
//  Generator
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation
import Tokenizer

public struct GeneratorConfiguration {
    public let minimumMajorVersion: Int
    public let localXmlPath: String
    public let isLiveEnabled: Bool
    public let swiftVersion: SwiftVersion
    public let defaultModifier: AccessModifier

    public init(minimumMajorVersion: Int,
                localXmlPath: String,
                isLiveEnabled: Bool,
                swiftVersion: SwiftVersion,
                defaultModifier: AccessModifier) {
        self.minimumMajorVersion = minimumMajorVersion
        self.localXmlPath = localXmlPath
        self.isLiveEnabled = isLiveEnabled
        self.swiftVersion = swiftVersion
        self.defaultModifier = defaultModifier
    }
}
