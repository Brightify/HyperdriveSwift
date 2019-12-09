//
//  AttributedTextTemplate.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct AttributedTextTemplate {
    public var attributedText: ElementAssignableProperty<Optional<Module.Foundation.AttributedText>.TypeFactory>
    public var arguments: [String]

    init(node: XMLElement) throws {
        let text = try Module.Foundation.AttributedText.materialize(from: node)
        let description = "attributedText"
        attributedText = ElementAssignableProperty(
            namespace: [],
            name: description,
            description: ElementAssignablePropertyDescription(
                namespace: [], name: description,
                swiftName: description, key: description,
                defaultValue: nil,
                typeFactory: Optional<Module.Foundation.AttributedText>.typeFactory),
            value: .value(text))
        arguments = []
        node.children.forEach {
            let tokens = Lexer.tokenize(input: $0.description)
            tokens.forEach { token in
                if case .argument(let argument) = token, !arguments.contains(argument) {
                    arguments.append(argument)
                }
            }
        }
    }
}
