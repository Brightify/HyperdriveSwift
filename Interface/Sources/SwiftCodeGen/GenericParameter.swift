//
//  GenericParameter.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct GenericParameter {
    public var name: String
    public var inheritance: String?

    public var description: String {
        return "\(name)\(inheritance.format(into: { ": \($0)" }))"
    }

    public init(name: String, inheritance: String? = nil) {
        self.name = name
        self.inheritance = inheritance
    }
}
