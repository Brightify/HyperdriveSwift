//
//  AppKit.View.swift
//  hyperdrive
//
//  Created by Matyáš Kříž on 26/06/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class View: UIElement, SwiftExtensionWorkaround {
        public class var availableProperties: [PropertyDescription] {
            return Properties.view.allProperties
        }

        public class var availableToolingProperties: [PropertyDescription] {
            return ToolingProperties.view.allProperties
        }

        // runtime type is used in generator for style parameters
        public class func runtimeType() throws -> String {
            return "NS\(self)"
        }

        public func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .iOS, .tvOS:
                return RuntimeType(name: "UI\(type(of: self))", module: "UIKit")
            case .macOS:
                return RuntimeType(name: "NS\(type(of: self))", module: "AppKit")
            }
        }

        public class var parentModuleImport: String {
            return "AppKit"
        }

        public var requiredImports: Set<String> {
            return ["AppKit"]
        }

        public let factory: UIElementFactory

        public var id: UIElementID
        public var isExported: Bool
        public var injectionOptions: UIElementInjectionOptions
        public var styles: [StyleName]
        public var layout: Layout
        public var properties: [Property]
        public var toolingProperties: [String: Property]
        public var handledActions: [HyperViewAction]

        public func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return [
                ViewTapAction()
            ]
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView {
            return NSView()
        }
        #endif

        #if canImport(SwiftCodeGen)
        public var extraDeclarations: [Structure] {
            return []
        }

        public func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression {
            return .constant("\(try runtimeType(for: platform).name)()")
        }
        #endif

        public required init(context: UIElementDeserializationContext, factory: UIElementFactory) throws {
            self.factory = factory
            let node = context.element
            id = try node.value(ofAttribute: "id", defaultValue: context.elementIdProvider.next(for: node.name))
            isExported = try node.value(ofAttribute: "export", defaultValue: false)
            injectionOptions = try node.value(ofAttribute: "injected", defaultValue: .none)
            layout = try node.value()
            styles = try node.value(ofAttribute: "style", defaultValue: []) as [StyleName]

            if node.name == "View" && node.count != 0 {
                throw TokenizationError(message: "View must not have any children, use Container instead.")
            }

            properties = try PropertyHelper.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
            toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: type(of: self).availableToolingProperties, in: node)

            handledActions = try node.allAttributes.compactMap { _, value in
                try HyperViewAction(attribute: value)
            }
        }

        public init() {
            preconditionFailure("Not implemented!")
            //        id = nil
            isExported = false
            injectionOptions = .none
            styles = []
            layout = Layout(contentCompressionPriorityHorizontal: View.defaultContentCompression.horizontal,
                            contentCompressionPriorityVertical: View.defaultContentCompression.vertical,
                            contentHuggingPriorityHorizontal: View.defaultContentHugging.horizontal,
                            contentHuggingPriorityVertical: View.defaultContentHugging.vertical)
            properties = []
            toolingProperties = [:]
            handledActions = []
        }

        public func serialize(context: DataContext) -> XMLSerializableElement {
            var builder = XMLAttributeBuilder()
            if case .provided(let id) = id {
                builder.attribute(name: "id", value: id)
            }
            if isExported {
                builder.attribute(name: "export", value: "true")
            }
            let styleNames = styles.map { $0.serialize() }.joined(separator: " ")
            if !styleNames.isEmpty {
                builder.attribute(name: "style", value: styleNames)
            }

            #if SanAndreas
            (properties + toolingProperties.values)
                .map {
                    $0.dematerialize(context: PropertyContext(parentContext: context, property: $0))
                }
                .forEach {
                    builder.add(attribute: $0)
            }
            #endif

            layout.serialize().forEach { builder.add(attribute: $0) }

            let typeOfSelf = type(of: self)
            #warning("TODO Implement")
            fatalError("Not implemented")
            let name = "" // ElementMapping.mapping.first(where: { $0.value == typeOfSelf })?.key ?? "\(typeOfSelf)"
            return XMLSerializableElement(name: name, attributes: builder.attributes, children: [])
        }
    }

    public class ViewProperties: PropertyContainer {
        // TODO: Add option to translate "backgroundColor" to "layer.backgroundColor"?
        public let isHidden: StaticAssignablePropertyDescription<Bool>
        public let alphaValue: StaticAssignablePropertyDescription<Double>
        public let isOpaque: StaticAssignablePropertyDescription<Bool>
        public let autoresizesSubviews: StaticAssignablePropertyDescription<Bool>
        public let translatesAutoresizingMaskIntoConstraints: StaticAssignablePropertyDescription<Bool>
        public let tag: StaticAssignablePropertyDescription<Int>
//        public let visibility: StaticAssignablePropertyDescription<ViewVisibility>
//        public let collapseAxis: StaticAssignablePropertyDescription<ViewCollapseAxis>
        public let frame: StaticAssignablePropertyDescription<Rect>
        public let bounds: StaticAssignablePropertyDescription<Rect>
//
        public let layer: LayerProperties

        public required init(configuration: PropertyContainer.Configuration) {
            isHidden = configuration.property(name: "isHidden", key: "hidden")
            alphaValue = configuration.property(name: "alphaValue", defaultValue: 1)
            isOpaque = configuration.property(name: "isOpaque", key: "opaque", defaultValue: true)
            autoresizesSubviews = configuration.property(name: "autoresizesSubviews", defaultValue: true)
            translatesAutoresizingMaskIntoConstraints = configuration.property(name: "translatesAutoresizingMaskIntoConstraints", defaultValue: true)
            tag = configuration.property(name: "tag")
//            canBecomeFocused = configuration.property(name: "canBecomeFocused")
//            visibility = configuration.property(name: "visibility", defaultValue: .visible)
//            collapseAxis = configuration.property(name: "collapseAxis", defaultValue: .vertical)
            frame = configuration.property(name: "frame", defaultValue: .zero)
            bounds = configuration.property(name: "bounds", defaultValue: .zero)

            layer = configuration.namespaced(in: "layer", LayerProperties.self)

            super.init(configuration: configuration)
        }
    }
}
