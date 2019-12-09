//
//  Accessibility.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public enum Accessibility: String, ExpressibleByStringLiteral {
    case `internal`
    case `public`
    case `private`
    case `fileprivate`
    case `open`

    public init(stringLiteral value: String) {
        switch value {
        case Accessibility.internal.rawValue:
            self = .internal
        case Accessibility.public.rawValue:
            self = .public
        case Accessibility.private.rawValue:
            self = .private
        case Accessibility.fileprivate.rawValue:
            self = .fileprivate
        case Accessibility.open.rawValue:
            self = .open
        default:
            print("Warning: Accessibility '\(value)' cannot be instantiated. Using `internal`.")
            self = .internal
        }
    }

    public var description: String {
        switch self {
        case .internal:
            return ""
        default:
            return self.rawValue
        }
    }
}
