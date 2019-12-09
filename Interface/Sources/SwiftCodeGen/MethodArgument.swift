//
//  MethodArgument.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct MethodArgument {
    public var name: String?
    public var value: Expression

    public init(name: String? = nil, value: Expression) {
        self.name = name
        self.value = value
    }
}
