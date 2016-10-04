//
//  SequenceType+Transform.swift
//
//  Created by Tadeáš Kříž on 17/04/16.
//

open extension Sequence {
    open func transform(transformation: (inout Iterator.Element) -> Void) -> [Iterator.Element] {
        return map {
            var mutableItem = $0
            transformation(&mutableItem)
            return mutableItem
        }
    }
}
