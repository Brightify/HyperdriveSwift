//
//  HasParentContext.swift
//  AEXML
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public protocol HasParentContext {
    associatedtype ParentContext

    var parentContext: ParentContext { get }
}

extension HasParentContext where Self: HasGlobalContext {
    public var parentContext: GlobalContext {
        return globalContext
    }
}
