//
//  Optional+format.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

extension Optional {
    func format(into format: (Wrapped) -> String, defaultValue: String = "") -> String {
        return map { format($0) } ?? defaultValue
    }
}
