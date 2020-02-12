//
//  UIColorPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public enum UIColorPropertyType: TypedSupportedType, HasStaticTypeFactory {
    public static let black = UIColorPropertyType.color(.black)

    case color(Color)
    case themed(String)

    public static let typeFactory = TypeFactory()

    public func requiresTheme(context: DataContext) -> Bool {
        switch self {
        case .color:
            return false
        case .themed:
            return true
        }
    }

    public func isOptional(context: SupportedPropertyTypeContext) -> Bool {
        switch self {
        case .color(.absolute):
            return false
        case .color(.named(let name)) where Color.systemColorNames.contains(name):
            return false
        case .color(.named):
            return true
        case .themed(let themeName):
            return context.themed(color: themeName)?.isOptional(context: context) ?? true
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        let colorTypePrefix: String
        switch context.platform {
        case .iOS, .tvOS:
            colorTypePrefix = "UI"
        case .macOS:
            colorTypePrefix = "NS"
        }

        switch self {
        case .color(.absolute(let red, let green, let blue, let alpha)):
            return .constant("\(colorTypePrefix)Color(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))")
        case .color(.named(let name)) where Color.systemColorNames.contains(name):
            return .constant("\(colorTypePrefix)Color.\(name)")
        case .color(.named(let name)):
            return .invoke(target: .constant("UIColor"), arguments: [
                MethodArgument(name: "named", value: .constant("\"\(name)\"")),
                MethodArgument(name: "in", value: .constant("__resourceBundle")),
                MethodArgument(name: "compatibleWith", value: .constant("nil")),
            ])
        case .themed(let name):
            return .constant("theme.colors.\(name)")
        }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        switch color {
        case .absolute(let red, let green, let blue, let alpha):
            if alpha < 1 {
                let rgba: Int = Int(red * 255) << 24 | Int(green * 255) << 16 | Int(blue * 255) << 8 | Int(alpha * 255)
                return String(format:"#%08x", rgba)
            } else {
                let rgb: Int = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
                return String(format:"#%06x", rgb)
            }
        case .named(let name):
            return name
        }
    }
    #endif

    #if HyperdriveRuntime
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .color(.absolute(let red, let green, let blue, let alpha)):
            #if canImport(UIKit)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            #else
            return NSColor(red: red, green: green, blue: blue, alpha: alpha)
            #endif
        case .color(.named(let name)) where Color.systemColorNames.contains(name):
            #if canImport(UIKit)
            return UIColor.value(forKeyPath: "\(name)Color") as? UIColor
            #else
            return NSColor.value(forKeyPath: "\(name)Color") as? NSColor
            #endif
        case .color(.named(let name)):
            if #available(iOS 11.0, OSX 10.13, *) {
                #if canImport(UIKit)
                return UIColor(named: name, in: context.resourceBundle, compatibleWith: nil)
                #else
                return NSColor(named: name, in: context.resourceBundle, compatibleWith: nil)
                #endif
            } else {
                return nil
            }
        case .themed(let name):
            guard let themedColor = context.themed(color: name) else { return nil }
            return themedColor.runtimeValue(context: context.child(for: themedColor))
        }
    }
    #endif

    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = UIColorPropertyType

        public var xsdType: XSDType {
            return Color.xsdType
        }

        public init() { }

        public func typedMaterialize(from value: String) throws -> UIColorPropertyType {
            // we're not creating our own parser for this, so we will disallow using dots inside the values and instead enforce
            // using percent signs
            let colorComponents = value.components(separatedBy: "@").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            func getColor(from value: String) throws -> UIColorPropertyType {
                if let themedName = ApplicationDescription.themedValueName(value: value) {
                    return .themed(themedName)
                } else if Color.systemColorNames.contains(value) {
                    return .color(.named(value))
                } else if let materializedValue = Color(hex: value) {
                    return .color(materializedValue)
                } else {
                    return .color(.named(value))
                }
            }

            let base = try getColor(from: colorComponents[0])

            guard colorComponents.count > 1 else { return base }
            // note the `var color` that we're going to apply the modificators to
            guard case .color(var color) = base else {
                throw ParseError.message("Only direct colors support modifications for now.")
            }

            for colorComponent in colorComponents.dropFirst() {
                let procedure = try SimpleProcedure(from: colorComponent)
                // all of the current modifications require just one parameter
                // feel free to change this in case you add a method that needs more than one
                guard let parameter = procedure.parameters.first, procedure.parameters.count == 1 else {
                    throw ParseError.message("Wrong number (\(procedure.parameters.count)) of parameters in procedure \(procedure.name).")
                }

                let trimmedValue = parameter.value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                let floatValue: CGFloat
                if let probablePercentSign = trimmedValue.last, probablePercentSign == "%", let value = Int(trimmedValue.dropLast()) {
                    floatValue = CGFloat(value) / 100
                } else if let value = Float(trimmedValue) {
                    floatValue = CGFloat(value)
                } else {
                    throw ParseError.message("\(parameter.value) is not a valid integer (with percent sign) nor floating point number to denote the value of the parameter in procedure \(procedure.name).")
                }

                func verifyLabel(correctLabel: String) throws {
                    if let label = parameter.label {
                        guard label == correctLabel else {
                            throw ParseError.message("Wrong label \(label) inside procedure \(procedure.name). \"\(correctLabel)\" or none should be used instead.")
                        }
                    }
                }

                switch procedure.name {
                case "lighter":
                    try verifyLabel(correctLabel: "by")
                    color = color.lighter(by: floatValue)
                case "darker":
                    try verifyLabel(correctLabel: "by")
                    color = color.darker(by: floatValue)
                case "saturated":
                    try verifyLabel(correctLabel: "by")
                    color = color.saturated(by: floatValue)
                case "desaturated":
                    try verifyLabel(correctLabel: "by")
                    color = color.desaturated(by: floatValue)
                case "fadedOut":
                    try verifyLabel(correctLabel: "by")
                    color = color.fadedOut(by: floatValue)
                case "fadedIn":
                    try verifyLabel(correctLabel: "by")
                    color = color.fadedIn(by: floatValue)
                case "alpha":
                    try verifyLabel(correctLabel: "at")
                    color = color.withAlphaComponent(floatValue)
                default:
                    throw ParseError.message("Unknown procedure \(procedure.name) used on color \(colorComponents[0]).")
                }
            }
            return .color(color)
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            switch platform {
            case .iOS, .tvOS:
                return RuntimeType(name: "UIColor", module: "UIKit")
            case .macOS:
                return RuntimeType(name: "NSColor", module: "AppKit")
            }
        }
    }
}
