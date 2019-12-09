//
//  HasGlobalContext.swift
//  AEXML
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public protocol HasGlobalContext: HasParentContext {
    var globalContext: GlobalContext { get }
}
