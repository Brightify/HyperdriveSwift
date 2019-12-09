//
//  GeneratorError.swift
//  CLI
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public struct GeneratorError: Error, LocalizedError {
    public let message: String

    public var errorDescription: String? {
        return message
    }

    public var localizedDescription: String {
        return message
    }
}
