//
//  CGAffineTransform+Shortcut.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if EnableHelperExtensions
import CoreGraphics

public extension CGAffineTransform {
    static func +(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
        return lhs.concatenating(rhs)
    }

    mutating func rotate(degrees: CGFloat) {
        self = rotated(degrees: degrees)
    }

    mutating func rotate(radians: CGFloat) {
        self = rotated(radians: radians)
    }

    mutating func translate(x: CGFloat = 0, y: CGFloat = 0) {
        self = translated(x: x, y: y)
    }

    mutating func scale(x: CGFloat = 1, y: CGFloat = 1) {
        self = scaled(x: x, y: y)
    }

    func rotated(degrees: CGFloat) -> CGAffineTransform {
        return concatenating(Self.rotate(degrees: degrees))
    }

    func rotated(radians: CGFloat) -> CGAffineTransform {
        return concatenating(Self.rotate(radians: radians))
    }

    func translated(x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
        return concatenating(Self.translate(x: x, y: y))
    }

    func scaled(x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
        return concatenating(Self.scale(x: x, y: y))
    }

    static func rotate(degrees: CGFloat) -> CGAffineTransform {
        return rotate(radians: degrees / 180 * .pi)
    }

    static func rotate(radians: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: radians)
    }

    static func translate(x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
        return CGAffineTransform(translationX: x, y: y)
    }

    static func scale(x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
        return CGAffineTransform(scaleX: x, y: y)
    }
}
#endif
