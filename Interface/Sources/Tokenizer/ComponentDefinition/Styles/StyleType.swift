//
//  StyleType.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

/**
 * Represents `Style`'s type.
 * Currently, there are:
 * - view: basic UI element styling
 * - attributedText: attributed string styling allowing multiple attributed style tags to be defined within it
 */
public enum StyleType {
    case view(factory: UIElementFactory)
    case attributedText(styles: [AttributedTextStyle])

    public var styleType: String {
        switch self {
        case .view(let type):
            return type.elementName
        case .attributedText:
            return "attributedText"
        }
    }
}
