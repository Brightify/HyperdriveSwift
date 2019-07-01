//
//  Foundation.AttributedText.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 25/05/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Array {
    fileprivate func arrayByAppending(_ elements: Element...) -> Array<Element> {
        return arrayByAppending(elements)
    }

    fileprivate func arrayByAppending(_ elements: [Element]) -> Array<Element> {
        var mutableCopy = self
        mutableCopy.append(contentsOf: elements)
        return mutableCopy
    }
}

extension Sequence {
    fileprivate func distinct(where comparator: (_ lhs: Iterator.Element, _ rhs: Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where !result.contains(where: { comparator(item, $0) }) {
            result.append(item)
        }
        return result
    }
}

extension Module.Foundation {
    public struct AttributedText: ElementSupportedPropertyType, TypedSupportedType, HasStaticTypeFactory {
        public static let typeFactory = TypeFactory()

        public let style: StyleName?
        public let localProperties: [Property]
        public let parts: [AttributedText.Part]

        public var requiresTheme: Bool {
            return localProperties.contains(where: { $0.anyValue.requiresTheme }) ||
                parts.contains(where: { $0.requiresTheme })
        }

        public enum Part {
            case transform(TransformedText)
            indirect case attributed(AttributedTextStyle, [AttributedText.Part])

            var requiresTheme: Bool {
                switch self {
                case .transform:
                    return false
                case .attributed(let style, let innerText):
                    return style.properties.contains(where: { $0.anyValue.requiresTheme }) ||
                        innerText.contains(where: { $0.requiresTheme })
                }
            }
        }
    }
}

extension Module.Foundation.AttributedText {
    public final class TypeFactory: TypedElementSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Module.Foundation.AttributedText

        public var xsdType: XSDType {
            return .builtin(.string)
        }

        public init() { }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "NSMutableAttributedString", module: "Foundation")
        }
    }
}

extension Module.Foundation.AttributedText {
    static let attributeKeys = [
        "font": NSAttributedString.Key.font,
        "foregroundColor": NSAttributedString.Key.foregroundColor,
        "backgroundColor": NSAttributedString.Key.backgroundColor,
        "ligature": NSAttributedString.Key.ligature,
        "kern": NSAttributedString.Key.kern,
        "underlineStyle": NSAttributedString.Key.underlineStyle,
        "underlineColor": NSAttributedString.Key.underlineColor,
        "striketroughStyle": NSAttributedString.Key.strikethroughStyle,
        "strikethroughColor": NSAttributedString.Key.strikethroughColor,
        "strokeColor": NSAttributedString.Key.strokeColor,
        "strokeWidth": NSAttributedString.Key.strokeWidth,
        "shadow": NSAttributedString.Key.shadow,
        "attachmentImage": NSAttributedString.Key.attachment,
        "link": NSAttributedString.Key.link,
        "baselineOffset": NSAttributedString.Key.baselineOffset,
        "obliqueness": NSAttributedString.Key.obliqueness,
        "expansion": NSAttributedString.Key.expansion,
        "writingDirection": NSAttributedString.Key.writingDirection,
        "verticalGlyphForm": NSAttributedString.Key.verticalGlyphForm,
        "paragraphStyle": NSAttributedString.Key.paragraphStyle,
    ] as [String: NSAttributedString.Key]

    public static func materialize(from element: XMLElement) throws -> Module.Foundation.AttributedText {
        let styleName = element.value(ofAttribute: "style") as StyleName?

        func parseTextElement(contents: [XMLContent]) throws -> [Module.Foundation.AttributedText.Part] {
            return try contents.map { content in
                switch content {
                case let textChild as TextElement:
                    return .transform(try TransformedText.materialize(from: textChild.text))
                case let elementChild as XMLElement:
                    let textStyle = try AttributedTextStyle(node: elementChild)
                    return .attributed(textStyle, try parseTextElement(contents: elementChild.children))
                default:
                    throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
                }
            }
        }

        func trimmingWhitespace(content: XMLContent, leading: Bool, indentationLevel: inout Int) throws -> XMLContent? {
            switch content {
            case let textChild as TextElement:
                let trimmedText = textChild.text.replacingOccurrences(of: leading ? "^\\s+" : "\\s+$",
                                                                      with: "",
                                                                      options: .regularExpression)
                if leading {
                    indentationLevel = textChild.text.count - trimmedText.count
                }
                guard !trimmedText.isEmpty else { return nil }
                return TextElement(text: trimmedText)

            case let elementChild as XMLElement:
                guard !elementChild.children.isEmpty else { return elementChild }
                let index = leading ? elementChild.children.startIndex : elementChild.children.endIndex
                guard let modifiedChild = try trimmingWhitespace(content: elementChild.children[index], leading: leading, indentationLevel: &indentationLevel)
                    else { return elementChild }
                elementChild.children[index] = modifiedChild
                return elementChild

            default:
                throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
            }
        }

        func fixingContentIndentation(content: XMLContent, indentationLevel: Int) throws -> XMLContent {
            switch content {
            case let textChild as TextElement:
                let fixedText = textChild.text.replacingOccurrences(
                    of: "\\n[ ]{0,\(indentationLevel)}",
                    with: "\\\n",
                    options: .regularExpression)
                return TextElement(text: fixedText)

            case let elementChild as XMLElement:
                let index = elementChild.children.startIndex
                elementChild.children[index] = try fixingContentIndentation(content: elementChild.children[index], indentationLevel: indentationLevel)
                return elementChild

            default:
                throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
            }
        }

        var indentationLevel = 0
        let trimmedContents: [XMLContent] = try element.children.enumerated().compactMap { (index, content) in
            switch index {
            case 0 where element.children.count == 1:
                guard let partialResult = try trimmingWhitespace(content: content, leading: true, indentationLevel: &indentationLevel) else { return nil }
                return try trimmingWhitespace(content: partialResult, leading: false, indentationLevel: &indentationLevel)
            case 0:
                return try trimmingWhitespace(content: content, leading: true, indentationLevel: &indentationLevel)
            case element.children.count - 1:
                let indentedContent = try fixingContentIndentation(content: content, indentationLevel: indentationLevel)
                return try trimmingWhitespace(content: indentedContent, leading: false, indentationLevel: &indentationLevel)
            default:
                return try fixingContentIndentation(content: content, indentationLevel: indentationLevel)
            }
        }

        let parsedText = try parseTextElement(contents: trimmedContents)
        // FIXME: `AttributedTextStyle` shouldn't be reused here and we should parse the properties ourselves
        let style = try AttributedTextStyle(node: element)
        return Module.Foundation.AttributedText(style: styleName, localProperties: style.properties, parts: parsedText)
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        var block = Block()

        block += .declaration(isConstant: true, name: "s", expression: .invoke(target: .constant("NSMutableAttributedString"), arguments: []))

        for (text, attributes) in generateStringParts(context: context) {
            block += Statement.expression(
                .invoke(target: .constant("s.append"), arguments: [
                    MethodArgument(value: .invoke(target: .member(target: text, name: "attributed"), arguments: attributes)),
                ])
            )
        }
        block += .return(expression: .constant("s"))

        let closure = Closure(block: block)

        return .invoke(target: .closure(closure), arguments: [])
    }

    private func generateStringParts(context: SupportedPropertyTypeContext) -> [(text: Expression, attributes: [MethodArgument])] {
        func resolveAttributes(part: Module.Foundation.AttributedText.Part, inheritedAttributes: [Property], parentElements: [String]) -> [(text: Expression, attributes: [MethodArgument])] {
            switch part {
            case .transform(let transformedText):
                let generatedAttributes = inheritedAttributes.map {
                    Expression.invoke(target: .constant(".\($0.name)"), arguments: [
                        .init(value: $0.anyValue.generate(context: context.child(for: $0.anyValue)))
                    ])
                }
                let generatedTransformedText = transformedText.generate(context: context.child(for: transformedText))
                let generatedParentStyles = parentElements.compactMap { elementName in
                    style.map { context.resolvedStyleName(named: $0) + ".\(elementName)" }
                }.distinctLast().map(Expression.constant)

                let attributesString = Expression.join(expressions: generatedParentStyles + [Expression.arrayLiteral(items: generatedAttributes)], operator: "+") ?? .arrayLiteral(items: [])

                return [(generatedTransformedText, [MethodArgument(value: attributesString)])]
            case .attributed(let attributedStyle, let attributedTexts):
                let resolvedAttributes: Set<String>
                if let styleName = style {
                    resolvedAttributes = Set(resolvedExtensions(of: attributedStyle, from: [styleName], in: context).map { $0.name })
                } else {
                    resolvedAttributes = []
                }
                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(inheritedAttributes.filter { !resolvedAttributes.contains($0.name) })
                    .distinct(where: { $0.name == $1.name })
                let newParentElements = parentElements + [attributedStyle.name]

                return attributedTexts.flatMap {
                    resolveAttributes(part: $0, inheritedAttributes: lowerAttributes, parentElements: newParentElements)
                }
            }
        }

        return parts.flatMap {
            resolveAttributes(part: $0, inheritedAttributes: localProperties, parentElements: [])
        }
    }
    #endif

    private func resolvedExtensions(of style: AttributedTextStyle, from styleNames: [StyleName], in context: SupportedPropertyTypeContext) -> [Property] {
        return styleNames.flatMap { styleName -> [Property] in
            guard let resolvedStyle = context.style(named: styleName),
                case .attributedText(let styles) = resolvedStyle.type,
                let extendedAttributeStyle = styles.first(where: { $0.name == style.name }) else { return [] }

            return extendedAttributeStyle.properties.arrayByAppending(resolvedExtensions(of: style, from: resolvedStyle.extend, in: context))
        }
    }

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        fatalError("Implement me!")
    }
    #endif

    #if HyperdriveRuntime
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        func resolveAttributes(part: Module.Foundation.AttributedText.Part, inheritedAttributes: [Property]) throws -> [NSAttributedString] {
            switch part {
            case .transform(let transformedText):
                guard let transformedText = transformedText.runtimeValue(context: context.child(for: transformedText)) as? String
                    else { return [] }

                let attributes = try Dictionary(inheritedAttributes.compactMap { attribute -> (NSAttributedString.Key, Any)? in
                    guard let attributeValue = try attribute.anyValue.runtimeValue(context: context.child(for: attribute.anyValue)),
                        let key = AttributedText.attributeKeys[attribute.name] else { return nil }
                    return (key, attributeValue)
                }, uniquingKeysWith: { $1 })
                return [NSAttributedString(string: transformedText, attributes: attributes)]

            case .attributed(let attributedStyle, let attributedTexts):
                let resolvedAttributes: [Property]
                if let styleName = style {
                    resolvedAttributes = resolvedExtensions(of: attributedStyle, from: [styleName], in: context)
                } else {
                    resolvedAttributes = []
                }

                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(resolvedAttributes)
                    .arrayByAppending(inheritedAttributes)
                    .distinct(where: { $0.name == $1.name })

                return try attributedTexts.flatMap {
                    try resolveAttributes(part: $0, inheritedAttributes: lowerAttributes)
                }
            }
        }

        let result = NSMutableAttributedString()
        try parts
            .flatMap { try resolveAttributes(part: $0, inheritedAttributes: localProperties) }
            .forEach { result.append($0) }
        return result
    }
    #endif
}

extension Module.Foundation {
    public class AttributedTextProperties: PropertyContainer {
        public let font: StaticAssignablePropertyDescription<Font?>
        public let foregroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let backgroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let ligature: StaticAssignablePropertyDescription<Int?>
        public let kern: StaticAssignablePropertyDescription<Double?>
        public let underlineStyle: StaticAssignablePropertyDescription<UnderlineStyle?>
        public let strikethroughStyle: StaticAssignablePropertyDescription<UnderlineStyle?>
        public let strokeColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let strokeWidth: StaticAssignablePropertyDescription<Double?>
        public let shadow: StaticMultipleAttributeAssignablePropertyDescription<Shadow?>
        public let textEffect: StaticAssignablePropertyDescription<String>
        public let attachmentImage: StaticAssignablePropertyDescription<Image?>
        public let link: StaticAssignablePropertyDescription<URL?>
        public let baselineOffset: StaticAssignablePropertyDescription<Double?>
        public let underlineColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let strikethroughColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let obliqueness: StaticAssignablePropertyDescription<Double?>
        public let expansion: StaticAssignablePropertyDescription<Double?>
        public let writingDirection: StaticAssignablePropertyDescription<WritingDirection?>
        public let verticalGlyphForm: StaticAssignablePropertyDescription<Int?>

        public let paragraphStyle: StaticMultipleAttributeAssignablePropertyDescription<ParagraphStyle?>

        public required init(configuration: Configuration) {
            font = configuration.property(name: "font")
            foregroundColor = configuration.property(name: "foregroundColor")
            backgroundColor = configuration.property(name: "backgroundColor")
            ligature = configuration.property(name: "ligature")
            kern = configuration.property(name: "kern")
            strikethroughStyle = configuration.property(name: "strikethroughStyle")
            underlineStyle = configuration.property(name: "underlineStyle")
            strokeColor = configuration.property(name: "strokeColor")
            strokeWidth = configuration.property(name: "strokeWidth")
            shadow = configuration.property(name: "shadow")
            textEffect = configuration.property(name: "textEffect")
            attachmentImage = configuration.property(name: "attachment")
            link = configuration.property(name: "link")
            baselineOffset = configuration.property(name: "baselineOffset")
            underlineColor = configuration.property(name: "underlineColor")
            strikethroughColor = configuration.property(name: "strikethroughColor")
            obliqueness = configuration.property(name: "obliqueness")
            expansion = configuration.property(name: "expansion")
            writingDirection = configuration.property(name: "writingDirection")
            verticalGlyphForm = configuration.property(name: "verticalGlyphForm")

            paragraphStyle = configuration.property(name: "paragraphStyle")

            super.init(configuration: configuration)
        }
    }
}
