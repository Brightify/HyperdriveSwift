//
//  ModuleRegistry.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 27/06/2019.
//

public struct ModuleRegistry {
    public typealias ReferenceFactoryProvider = (_ element: String) -> ComponentReferenceFactory

    public enum ModuleError: Error {
        case duplicateReferenceFactoryProvider
        case missingReferenceFactoryProvider
    }

    public let factories: [UIElementFactory]
    private let referenceFactoryProvider: ReferenceFactoryProvider

    public init(modules: [RuntimeModule], platform: RuntimePlatform) throws {
        let filteredModules = modules.filter { $0.supportedPlatforms.contains(platform) }
        let referenceFactoryProviders = filteredModules.compactMap { $0.referenceFactoryProvider }

        guard let referenceFactoryProvider = referenceFactoryProviders.first else {
            throw ModuleError.missingReferenceFactoryProvider
        }

        if referenceFactoryProviders.count > 1 {
            throw ModuleError.duplicateReferenceFactoryProvider
        } else {
            factories = filteredModules.flatMap { $0.elements(for: platform) }
            self.referenceFactoryProvider = referenceFactoryProvider
        }
    }

    public func referenceFactory(for element: String) -> ComponentReferenceFactory {
        return referenceFactoryProvider(element)
    }
}
