//
//  NSAttributedString+Attribute.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let mutableString = NSMutableAttributedString(attributedString: lhs)
    mutableString.append(rhs)
    return mutableString
}

public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
    return lhs.attributed() + rhs
}

public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    return lhs + rhs.attributed()
}

public extension String {

    /**
     * Allows you to easily create an `NSAttributedString` out of regular `String`
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which NSAttributedString is created
     * ## Example
     * ```
     * let attributedString = "Beautiful String".attributed(.kern(1.2), .strokeWidth(1), .strokeColor(.red))
     * ```
     */
    func attributed(_ attributes: [Attribute]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes.toDictionary())
    }

    /**
     * Allows you to easily create an `NSAttributedString` out of regular `String`
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which NSAttributedString is created
     * ## Example
     * ```
     * let attributedString = "Beautiful String".attributed(.kern(1.2), .strokeWidth(1), .strokeColor(.red))
     * ```
     */
    func attributed(_ attributes: Attribute...) -> NSAttributedString {
        return attributed(attributes)
    }
}

public protocol AttributedStringConvertible {
    func toAttributedString() -> NSAttributedString
}

extension NSAttributedString: AttributedStringConvertible {
    public func toAttributedString() -> NSAttributedString {
        return self
    }
}

extension String: AttributedStringConvertible {
    public func toAttributedString() -> NSAttributedString {
        return NSAttributedString(string: self)
    }
}

extension Sequence where Element == AttributedStringConvertible {
    public func joined() -> NSAttributedString {
        return reduce(into: NSMutableAttributedString()) {
            $0.append($1.toAttributedString())
        }
    }

    public func joined(separator: @autoclosure () -> AttributedStringConvertible) -> NSAttributedString {
        return enumerated().reduce(into: NSMutableAttributedString()) {
            if $1.offset != 0 {
                $0.append(separator().toAttributedString())
            }
            $0.append($1.element.toAttributedString())
        }
    }
}

extension Array: AttributedStringConvertible where Element == AttributedStringConvertible {
    public func toAttributedString() -> NSAttributedString {
        return joined()
    }
}

#if swift(>=5.1)
@_functionBuilder
public struct AttributedStringBuilder {
    public static func buildBlock(_ segments: AttributedStringConvertible...) -> NSAttributedString {
        return segments.joined()
    }
}

public extension NSAttributedString {
    convenience init(@AttributedStringBuilder _ content: () -> NSAttributedString) {
        self.init(attributedString: content())
    }
}
#endif
#endif
