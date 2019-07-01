//
//  Module+Foundation.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 26/06/2019.
//

import Foundation

extension Module {
    public static let foundation = Foundation()

    public struct Foundation: RuntimeModule {
        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
            .tvOS,
            .macOS,
        ]

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            return []
        }
    }
}
