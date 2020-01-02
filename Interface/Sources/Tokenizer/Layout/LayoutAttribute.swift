//
//  LayoutAttribute.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum LayoutAttribute: Hashable {
    case leading
    case trailing
    case left
    case right
    case top
    case bottom
    case width
    case height
    case before
    case after
    case above
    case below
    case centerX
    case centerY
    case firstBaseline
    case lastBaseline
    case size
    indirect case margin(LayoutAttribute)

    public var insetDirection: Double {
        switch self {
        case .leading, .left, .top, .before, .above:
            return 1
        case .trailing, .right, .bottom, .width, .height, .after, .below, .centerY, .centerX, .firstBaseline, .lastBaseline, .size:
            return -1
        case .margin(let inner):
            return inner.insetDirection
        }
    }

    static func deserialize(_ string: String) throws -> [LayoutAttribute] {
        let marginSuffix = ".margin"
        if string.hasSuffix(marginSuffix) {
            return try Self.deserialize(String(string.dropLast(marginSuffix.count))).map(Self.margin)
        }

        switch string {
        case "leading":
            return [.leading]
        case "trailing":
            return [.trailing]
        case "left":
            return [.left]
        case "right":
            return [.right]
        case "top":
            return [.top]
        case "bottom":
            return [.bottom]
        case "width":
            return [.width]
        case "height":
            return [.height]
        case "before":
            return [.before]
        case "after":
            return [.after]
        case "above":
            return [.above]
        case "below":
            return [.below]
        case "edges":
            return [.left, .right, .top, .bottom]
        case "fillHorizontally", "horizontalEdges":
            return [.left, .right]
        case "fillVertically", "verticalEdges", "directionalVerticalEdges":
            return [.top, .bottom]
        case "directionalEdges":
            return [.leading, .trailing, .top, .bottom]
        case "directionalHorizontalEdges":
            return [.leading, .trailing]
        case "centerX":
            return [.centerX]
        case "centerY":
            return [.centerY]
        case "center":
            return [.centerX, .centerY]
        case "firstBaseline":
            return [.firstBaseline]
        case "lastBaseline":
            return [.lastBaseline]
        case "size":
            return [.size]
        case "margins":
            return [.left, .right, .top, .bottom].map(Self.margin)
        case "directionalMargins":
            return [.leading, .trailing, .top, .bottom].map(Self.margin)
        default:
            throw TokenizationError(message: "Unknown layout attribute \(string)")
        }
    }

    public var anchor: LayoutAnchor {
        switch self {
        case .top, .below:
            return .top
        case .bottom, .above:
            return .bottom
        case .leading, .after:
            return .leading
        case .trailing, .before:
            return .trailing
        case .left:
            return .left
        case .right:
            return .right
        case .width:
            return .width
        case .height:
            return .height
        case .centerY:
            return .centerY
        case .centerX:
            return .centerX
        case .firstBaseline:
            return .firstBaseline
        case .lastBaseline:
            return .lastBaseline
        case .size:
            return .size
        case .margin(let inner):
            return .margin(inner.anchor)
        }
    }

    public var targetAnchor: LayoutAnchor {
        switch self {
        case .top, .above:
            return .top
        case .bottom, .below:
            return .bottom
        case .leading, .before:
            return .leading
        case .trailing, .after:
            return .trailing
        case .left:
            return .left
        case .right:
            return .right
        case .width:
            return .width
        case .height:
            return .height
        case .centerY:
            return .centerY
        case .centerX:
            return .centerX
        case .firstBaseline:
            return .firstBaseline
        case .lastBaseline:
            return .lastBaseline
        case .size:
            return .size
        case .margin(let inner):
            return .margin(inner.targetAnchor)
        }
    }
}
