//
//  MethodParameter.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct MethodParameter {
    public var label: String?
    public var name: String
    public var type: String
    public var defaultValue: String?

    public var description: String {
        return "\(label.format(into: { "\($0) " }))\(name): \(type)\(defaultValue.format(into: { " = \($0)" }))"
    }

    public init(label: String? = nil, name: String, type: String, defaultValue: String? = nil) {
        self.label = label
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}
