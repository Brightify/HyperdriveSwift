//
//  Attributes.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Attributes: ExpressibleByArrayLiteral {
    private let attributes: [String]

    public init(arrayLiteral elements: String...) {
        self.attributes = elements
    }

    public init(_ attributes: [String] = []) {
        self.attributes = attributes
    }

    public func describe(into pipe: DescriptionPipe) {
        pipe.lines(attributes)
    }
}

