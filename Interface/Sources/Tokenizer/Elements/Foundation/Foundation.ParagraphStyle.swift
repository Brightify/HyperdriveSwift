//
//  Foundation.ParagraphStyle.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Module.Foundation {
    public struct ParagraphStyle: MultipleAttributeSupportedPropertyType, TypedSupportedType, HasStaticTypeFactory {
        public static let typeFactory = TypeFactory()

        public let properties: [Property]

        #if canImport(SwiftCodeGen)
        public func generate(context: SupportedPropertyTypeContext) -> Expression {
            var block = Block()
            block += .declaration(isConstant: true, name: "p", expression: .constant("NSMutableParagraphStyle()"))

            for property in properties {
                block += .assignment(
                    target: .member(target: .constant("p"), name: property.name),
                    expression: property.anyValue.generate(context: context.child(for: property.anyValue)))
            }

            block += .return(expression: .constant("p"))

            let closure = Closure(block: block)

            return .invoke(target: .closure(closure), arguments: [])
        }
        #endif

        #if SanAndreas
        // TODO
        public func dematerialize(context: SupportedPropertyTypeContext) -> String {
            fatalError("Implement me!")
        }
        #endif

        public static func materialize(from attributes: [String: String]) throws -> ParagraphStyle {
            let properties = Properties.paragraphStyle.allProperties.compactMap { $0 as? AttributePropertyDescription }

            return try ParagraphStyle(properties: PropertyHelper.deserializeSupportedProperties(properties: properties, from: attributes))
        }

        public class TypeFactory: TypedMultipleAttributeSupportedTypeFactory {
            public typealias BuildType = Module.Foundation.ParagraphStyle

            public var xsdType: XSDType {
                return .builtin(.string)
            }

            public init() { }

            public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
                return RuntimeType(name: "NSMutableParagraphStyle", module: "Foundation")
            }
        }
    }

    public class ParagraphStyleProperties: PropertyContainer {
        public let alignment: StaticAssignablePropertyDescription<TextAlignment>
        public let firstLineHeadIndent: StaticAssignablePropertyDescription<Double>
        public let headIndent: StaticAssignablePropertyDescription<Double>
        public let tailIndent: StaticAssignablePropertyDescription<Double>
//    public let tabStops: StaticAssignablePropertyDescription<[TextTab]>
        public let lineBreakMode: StaticAssignablePropertyDescription<LineBreakMode>
        public let maximumLineHeight: StaticAssignablePropertyDescription<Double>
        public let minimumLineHeight: StaticAssignablePropertyDescription<Double>
        public let lineHeightMultiple: StaticAssignablePropertyDescription<Double>
        public let lineSpacing: StaticAssignablePropertyDescription<Double>
        public let paragraphSpacing: StaticAssignablePropertyDescription<Double>
        public let paragraphSpacingBefore: StaticAssignablePropertyDescription<Double>

        public required init(configuration: Configuration) {
            let defaultTabStops = (1...12).map { i in
                TextTab(textAlignment: .left, location: Double(28 * i))
            }

            alignment = configuration.property(name: "alignment", defaultValue: .natural)
            firstLineHeadIndent = configuration.property(name: "firstLineHeadIndent")
            headIndent = configuration.property(name: "headIndent")
            tailIndent = configuration.property(name: "tailIndent")
//        tabStops = configuration.property(name: "tabStops", defaultValue: defaultTabStops)
            lineBreakMode = configuration.property(name: "lineBreakMode", defaultValue: .byWordWrapping)
            maximumLineHeight = configuration.property(name: "maximumLineHeight")
            minimumLineHeight = configuration.property(name: "minimumLineHeight")
            lineHeightMultiple = configuration.property(name: "lineHeightMultiple")
            lineSpacing = configuration.property(name: "lineSpacing")
            paragraphSpacing = configuration.property(name: "paragraphSpacing")
            paragraphSpacingBefore = configuration.property(name: "paragraphSpacingBefore")

            super.init(configuration: configuration)
        }
    }
}

#if HyperdriveRuntime
extension Module.Foundation.ParagraphStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        let paragraphStyle = NSMutableParagraphStyle()
        for property in properties {
            let value = try property.anyValue.runtimeValue(context: context.child(for: property.anyValue))
            paragraphStyle.setValue(value, forKey: property.name)
        }
        return paragraphStyle
    }
}
#endif
