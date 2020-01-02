//
//  LayoutAnchor.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum LayoutAnchor: CustomStringConvertible, Hashable {
    case top
    case bottom
    case leading
    case trailing
    case left
    case right
    case width
    case height
    case centerX
    case centerY
    case firstBaseline
    case lastBaseline
    case size
    indirect case margin(LayoutAnchor)

    public var description: String {
        switch self {
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        case .left:
            return "left"
        case .right:
            return "right"
        case .width:
            return "width"
        case .height:
            return "height"
        case .centerX:
            return "centerX"
        case .centerY:
            return "centerY"
        case .firstBaseline:
            return "firstBaseline"
        case .lastBaseline:
            return "lastBaseline"
        case .size:
            return "size"
        case .margin(let inner) where [.leading, .left, .top, .bottom, .right, .trailing].contains(inner):
            return "\(inner.description)Margin"
        case .margin(let inner) where [.centerX, .centerY].contains(inner):
            return "\(inner.description)WithinMargins"
        case .margin(let inner):
            return inner.description
        }
    }

    init(_ string: String, attribute: LayoutAttribute) throws {
        let marginSuffix = ".margin"
        if string.hasSuffix(marginSuffix) {
            self = try Self(String(string.dropLast(marginSuffix.count)), attribute: attribute)
        }

        switch string {
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "left":
            self = .left
        case "right":
            self = .right
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "width":
            self = .width
        case "height":
            self = .height
        case "centerX":
            self = .centerX
        case "centerY":
            self = .centerY
        case "firstBaseline":
            self = .firstBaseline
        case "lastBaseline":
            self = .lastBaseline
        case "size":
            self = .size
        case "margin":
            self = Self.margin(attribute.targetAnchor).flattenMargins()
        default:
            throw TokenizationError(message: "Unknown layout anchor \(string)")
        }
    }

    private func flattenMargins() -> Self {
        if case .margin(let inner) = self {
            return inner.flattenMargins()
        } else {
            return .margin(self)
        }
    }
}
