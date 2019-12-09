//
//  SwiftVersion.swift
//  Generator
//
//  Created by Tadeas Kriz on 09/12/2019.
//

import Foundation

public enum SwiftVersion: Int {
    case swift4_0
    case swift4_1

    public init?(raw: String) {
        switch raw {
        case "4.0":
            self = .swift4_0
        case "4.1":
            self = .swift4_1
        default:
            return nil
        }
    }
}

extension SwiftVersion: Comparable {
    public static func <(lhs: SwiftVersion, rhs: SwiftVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
