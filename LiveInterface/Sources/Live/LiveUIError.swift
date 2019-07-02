//
//  LiveUIError.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public struct LiveUIError: Error {
    let message: String

    public init(message: String) {
        self.message = message
    }
}
