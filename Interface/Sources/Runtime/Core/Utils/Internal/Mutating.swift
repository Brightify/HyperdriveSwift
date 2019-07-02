//
//  Mutating.swift
//  HyperdriveInterface
//
//  Created by Tadeas Kriz on 15/06/2019.
//

internal func mutating<T>(_ value: T, mutation: (inout T) -> Void) -> T {
    var mutableValue = value
    mutation(&mutableValue)
    return mutableValue
}

internal func mutate<T>(_ value: inout T, mutation: (inout T) -> Void) {
    value = mutating(value, mutation: mutation)
}
