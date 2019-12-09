//
//  RuntimeModule.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public protocol RuntimeModule {
    var supportedPlatforms: Set<RuntimePlatform> { get }

    var referenceFactory: ComponentReferenceFactory? { get }

    func elements(for platform: RuntimePlatform) -> [UIElementFactory]
}

extension RuntimeModule {
    public var referenceFactory: ComponentReferenceFactory? {
        return nil
    }
}
