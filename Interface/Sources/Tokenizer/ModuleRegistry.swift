//
//  ModuleRegistry.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 27/06/2019.
//

public struct ModuleRegistry {
    public enum ModuleError: Error {
        case duplicateReferenceFactory
        case missingReferenceFactory
    }

    public let factories: [UIElementFactory]
    public let referenceFactory: ComponentReferenceFactory

    public init(modules: [RuntimeModule], platform: RuntimePlatform) throws {
        let filteredModules = modules.filter { $0.supportedPlatforms.contains(platform) }
        let referenceFactories = filteredModules.compactMap { $0.referenceFactory }

        guard let referenceFactory = referenceFactories.first else {
            throw ModuleError.missingReferenceFactory
        }

        if referenceFactories.count > 1 {
            throw ModuleError.duplicateReferenceFactory
        } else {
            factories = filteredModules.flatMap { $0.elements(for: platform) }
            self.referenceFactory = referenceFactory
        }
    }
}
