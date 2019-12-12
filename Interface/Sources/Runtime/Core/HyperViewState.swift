//
//  HyperViewState.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

public protocol HyperViewState: AnyObject {
    init()

    func apply(from otherState: Self)

    func resynchronize()
}

public final class EmptyState: HyperViewState {
    public init() { }

    public func apply(from otherState: EmptyState) { }

    public func resynchronize() { }
}

public extension HyperViewState {
    func apply(mutation: (Self) throws -> Void) rethrows -> Self {
        mutation(self)
        return self
    }
}
