//
//  TemplateType.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

/**
 * Represents `Template`'s type.
 * Currently, there are:
 * - attributedText: attributed string styling allowing multiple attributed style tags with custom arguments to be defined within it
 */
public enum TemplateType {
    case attributedText(template: AttributedTextTemplate)

    public var styleType: String {
        switch self {
        case .attributedText:
            return "attributedText"
        }
    }
}
