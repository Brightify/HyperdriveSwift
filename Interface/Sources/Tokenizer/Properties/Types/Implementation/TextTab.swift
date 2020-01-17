//
//  TextTab.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct TextTab: TypedSupportedType, HasStaticTypeFactory {
    public static let typeFactory = TypeFactory()

    public let textAlignment: TextAlignment
    public let location: Double

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        let generatedTextAlignment = textAlignment.generate(context: context.child(for: textAlignment))
        let generatedLocation = location.generate(context: context.child(for: location))
        return .invoke(target: .constant("NSTextTab"), arguments: [
            .init(name: "textAlignment", value: generatedTextAlignment),
            .init(name: "location", value: generatedLocation),
        ])
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        // TODO: format - "center@4"
        fatalError("Implement me!")
    }
    #endif

    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = TextTab

        public var xsdType: XSDType {
            return .pattern(PatternXSDType(name: "TextTab", base: .string, value: "??"))
        }

        public init() { }

        public func typedMaterialize(from value: String) throws -> TextTab {
            let components = value.components(separatedBy: "@")
            switch components.count {
            case 2:
                let (textAlignment, location) = try (TextAlignment.typeFactory.typedMaterialize(
                    from: components[0]), Double.typeFactory.typedMaterialize(from: components[1]))
                return TextTab(textAlignment: textAlignment, location: location)
            case 1:
                let location = try Double.typeFactory.typedMaterialize(from: components[0])
                return TextTab(textAlignment: .left, location: location)
            default:
                throw XMLDeserializationError.NodeHasNoValue
            }
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "NSTextTab", module: "Foundation")
        }
    }
}

#if canImport(UIKit)
import UIKit

extension TextTab {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        guard let textAlignmentRawValue = textAlignment.runtimeValue(context: context.child(for: textAlignment)) as? Int,
           let textAlignmentValue = NSTextAlignment(rawValue: textAlignmentRawValue) else { return nil }
        return NSTextTab(textAlignment: textAlignmentValue, location: CGFloat(location))
    }
}
#endif
