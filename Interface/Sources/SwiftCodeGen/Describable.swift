//
//  Describable.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public protocol Describable {
    func describe(into pipe: DescriptionPipe)
}

public func +(lhs: Describable, rhs: Describable) -> Describable {
    let pipe = DescriptionPipe()
    pipe.append(lhs)
    pipe.append(rhs)
    return pipe
}

extension String: Describable {
    public func describe(into pipe: DescriptionPipe) {
        pipe.lineEnd(self)
    }
}

extension Array: Describable where Element == Describable {
    public func describe(into pipe: DescriptionPipe) {
        forEach {
            $0.describe(into: pipe)
        }
    }
}
