//
//  Element+Root.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

public protocol ComponentDefinitionContainer {
    var componentTypes: [String] { get }

    var componentDefinitions: [ComponentDefinition] { get }
}

public enum AccessModifier: String {
    case `public`
    case `internal`
}

public struct NavigationItem {
    public var leftBarButtonItems: BarButtonItemContainer?
    public var rightBarButtonItems: BarButtonItemContainer?

    public var allItems: [BarButtonItem] {
        return (leftBarButtonItems?.items ?? []) + (rightBarButtonItems?.items ?? [])
    }

    public init(element: XMLElement) throws {
        leftBarButtonItems = try element.singleOrNoElement(named: "leftBarButtonItems").map(BarButtonItemContainer.init)
        rightBarButtonItems = try element.singleOrNoElement(named: "rightBarButtonItems").map(BarButtonItemContainer.init)
    }

    public struct BarButtonItemContainer {
        public var items: [BarButtonItem]

        public init(element: XMLElement) throws {
            items = try element.xmlChildren.map(BarButtonItem.init)
        }
    }

    public struct BarButtonItem {
        public var id: String
        public var isExported: Bool
        public var kind: Kind

        public init(element: XMLElement) throws {
            id = element.name
            isExported = element.value(ofAttribute: "export") ?? false

            let style = try element.singleOrNoElement(named: "style").map { try Kind.Style(from: $0.nonEmptyTextOrThrow()) }
            if let systemElement = try element.singleOrNoElement(named: "system") {
                guard let systemItem = try Kind.SystemItem(rawValue: systemElement.nonEmptyTextOrThrow()) else {
                    throw TokenizationError(message: "Unsupported system item '\(systemElement.text ?? "")'.")
                }
                kind = .system(systemItem)

            } else if let title = try element.singleOrNoElement(named: "title") {
                kind = .title(title.text ?? "", style: style ?? .plain)
            } else if let imageElement = try element.singleOrNoElement(named: "image") {
                let landscapeImagePhone = try element.singleOrNoElement(named: "landscapeImagePhone").map {
                    try Image.materialize(from: $0.nonEmptyTextOrThrow())
                }

                let image = try Image.materialize(from: imageElement.nonEmptyTextOrThrow())
                kind = .image(image, landscapeImagePhone: landscapeImagePhone, style: style ?? .plain)
            } else {
                throw TokenizationError(message: "Unknown barButtonItem type!")
            }
        }

        public enum Kind {
            case system(SystemItem)
            case title(String, style: Style = .plain)
            case image(Image, landscapeImagePhone: Image?, style: Style = .plain)
            case view(Module.UIKit.View)

            public enum Style: String {
                case plain
                case done

                init(from name: String) throws {
                    guard let style = Style(rawValue: name) else {
                        throw TokenizationError(message: "Unknown BarButtonItem style \(name)!")
                    }
                    self = style
                }
            }

            public enum SystemItem: String {
                case done
                case cancel
                case edit
                case save
                case add
                case flexibleSpace
                case fixedSpace
                case compose
                case reply
                case action
                case organize
                case bookmarks
                case search
                case refresh
                case stop
                case camera
                case trash
                case play
                case pause
                case rewind
                case fastForward
                case undo
                case redo
            }
        }
    }
}

/**
 * Contains the structure of a Component's file.
 */
public struct ComponentDefinition: UIContainer, UIElementBase, StyleContainer, ComponentDefinitionContainer {
    public var type: String
    public var isRootView: Bool
    public var styles: [Style]
    public var stylesName: String
    public var templates: [Template]
    public var templatesName: String
    public var children: [UIElement]
    public var edgesForExtendedLayout: [RectEdge]
    public var isAnonymous: Bool
    public var modifier: AccessModifier
    public var handledActions: [HyperViewAction]
    public var properties: [Property]
    public var toolingProperties: [String: Property]
    public var overrides: [Override]
    public var stateDescription: StateDescription
    public var navigationItem: NavigationItem?

    public static var parentModuleImport: String {
        return "Hyperdrive"
    }

    public var requiredImports: Set<String> {
        return Set(arrayLiteral: "Hyperdrive").union(children.flatMap { $0.requiredImports })
    }

    public var componentTypes: [String] {
        return [type] + ComponentDefinition.componentTypes(in: children)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return [self] + ComponentDefinition.componentDefinitions(in: children)
    }

    public var addSubviewMethod: String {
        return "addSubview"
    }

    #if canImport(UIKit)
    /**
     * **[LiveUI]** Adds a `UIView` to the passed self.
     * - parameter subview: view to be added as a subview
     * - parameter toInstanceOfSelf: parent to which the view should be added
     */
    public func add(subview: UIView, toInstanceOfSelf: UIView) {
        toInstanceOfSelf.addSubview(subview)
    }
    #endif

    public init(context: ComponentDeserializationContext) throws {
        let node = context.element
        type = context.type
        styles = try node.singleOrNoElement(named: "styles")?.xmlChildren.compactMap { try context.deserialize(element: $0, groupName: nil) } ?? []
        stylesName = try node.singleOrNoElement(named: "styles")?.attribute(by: "name")?.text ?? "Styles"
        templates = try node.singleOrNoElement(named: "templates")?.xmlChildren.compactMap { try $0.value() as Template } ?? []
        templatesName = try node.singleOrNoElement(named: "templates")?.attribute(by: "name")?.text ?? "Templates"
        children = try node.xmlChildren.compactMap(context.deserialize(element:))
        isRootView = node.value(ofAttribute: "rootView") ?? false
        if isRootView {
            edgesForExtendedLayout = (node.attribute(by: "extend")?.text).map(RectEdge.parse) ?? []
        } else {
            if node.attribute(by: "extend") != nil {
                Logger.instance.warning("Using `extend` without specifying `rootView=true` is redundant.")
            }
            edgesForExtendedLayout = []
        }
        isAnonymous = node.value(ofAttribute: "anonymous") ?? false
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            self.modifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            self.modifier = .internal
        }
        handledActions = try node.allAttributes.compactMap { _, value in
            try HyperViewAction(attribute: value)
        }

        let toolingPropertyDescriptions: [PropertyDescription]
        let propertyDescriptions: [PropertyDescription]
        switch context.platform {
        case .iOS, .tvOS:
            toolingPropertyDescriptions = Module.UIKit.ToolingProperties.componentDefinition.allProperties
            propertyDescriptions = Module.UIKit.View.availableProperties
        case .macOS:
            toolingPropertyDescriptions = Module.AppKit.ToolingProperties.componentDefinition.allProperties
            propertyDescriptions = Module.AppKit.View.availableProperties
        }
        toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: toolingPropertyDescriptions, in: node)
        properties = try PropertyHelper.deserializeSupportedProperties(properties: propertyDescriptions, in: node)
        overrides = try node.singleOrNoElement(named: "overrides")?.allAttributes.values.map(Override.init) ?? []
        stateDescription = try StateDescription(element: node.singleOrNoElement(named: "state"))
        navigationItem = try node.singleOrNoElement(named: "navigationItem").map(NavigationItem.init(element:))

        handledActions.append(contentsOf: navigationItem?.allItems.map { item in
            HyperViewAction(name: item.id, eventName: BarButtonItemTapAction.primaryName(for: item), parameters: [])
        } ?? [])

        // here we gather all the constraints' fields that do not have a condition and check if any are duplicate
        // in that case we warn the user about it, because it's probably not what they intended
        let fields = children.flatMap { $0.layout.constraints.compactMap { return $0.condition == nil ? $0.field : nil } }.sorted()
        for (index, field) in fields.enumerated() {
            let nextIndex = index + 1
            guard nextIndex < fields.count else { break }
            if field == fields[nextIndex] {
                Logger.instance.warning("Duplicate constraint names for name \"\(field)\". The project will be compilable, but the behavior might be unexpected.")
            }
        }
    }
}

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public class ComponentDefinitionAction: UIElementAction {
    public let primaryName: String

    public let aliases: Set<String> = []

    public let parameters: [Parameter]

    init(action: ResolvedHyperViewAction) {
        primaryName = action.name
        parameters = action.parameters.map { parameter in
            Parameter(label: parameter.label, type: parameter.type)
        }
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        let listener = Closure(captures: handler.captures, parameters: [(name: "action", type: nil)], block: [
            .if(condition: [.enumUnwrap(case: primaryName, parameters: handler.innerParameters, expression: .constant("action"))], then: [handler.publisher], else: nil)
            ])

        return .expression(.invoke(target: .member(target: view, name: "actionPublisher.listen"), arguments: [
            MethodArgument(name: "with", value: .closure(listener)),
        ]))
    }
    #endif
}

extension ComponentDefinition {
    public func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
//        let resolvedActions = try context.resolve(actions: providedActions)
//
//        let actions = resolvedActions.map { action in
//            ComponentDefinitionAction(action: action)
//        }
        let navigationItemActions = navigationItem?.allItems.map(BarButtonItemTapAction.init) ?? []
        return [
            ViewTapAction(),
        ] + navigationItemActions
    }
}

public class BarButtonItemTapAction: UIElementAction {
    public let primaryName: String

    public let aliases: Set<String> = []

    public let parameters: [Parameter] = []

    private let item: NavigationItem.BarButtonItem

    init(item: NavigationItem.BarButtonItem) {
        self.item = item
        primaryName = Self.primaryName(for: item)
    }

    public static func primaryName(for item: NavigationItem.BarButtonItem) -> String {
        return "tapBarButtonItem_\(item.id)"
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        return .expression(.invoke(target: .constant("UIBarButtonItemObserver.bind"), arguments: [
            MethodArgument(name: "to", value: Expression.member(target: view, name: item.id)),
            MethodArgument(name: "handler", value: .closure(handler.listener)),
        ]))
    }
    #endif
}

extension ComponentDefinition {
    static func componentTypes(in elements: [UIElement]) -> [String] {
        return elements.flatMap { element -> [String] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentTypes
            case let container as UIContainer:
                return componentTypes(in: container.children)
            default:
                return []
            }
        }
    }

    static func componentDefinitions(in elements: [UIElement]) -> [ComponentDefinition] {
        return elements.flatMap { element -> [ComponentDefinition] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentDefinitions
            case let container as UIContainer:
                return componentDefinitions(in: container.children)
            default:
                return []
            }
        }
    }
}

public final class ComponentDefinitionToolingProperties: PropertyContainer {
    public let preferredSize: StaticValuePropertyDescription<PreferredSize>

    public required init(configuration: Configuration) {
        preferredSize = configuration.property(name: "tools:preferredSize", defaultValue: PreferredSize(width: .fill, height: .wrap))
        super.init(configuration: configuration)
    }
}

extension ComponentDefinition {
    public struct StateDescription {
        public struct Item {
            public var name: String
            public var type: String
            public var defaultValue: String?
            public var isOptional: Bool
            public var handler: String?

            public init(element: XMLElement) throws {
                name = element.name

                guard let type = element.attribute(by: "type")?.text else {
                    throw TokenizationError(message: "State item is required to have a `type` attribute!")
                }
                self.type = type

                defaultValue = element.attribute(by: "default")?.text
                isOptional = element.attribute(by: "optional")?.text.lowercased() == "true"

                handler = element.attribute(by: "receiver")?.text
            }
        }

        public var items: [Item]

        public init(element: XMLElement?) throws {
            guard let element = element else {
                items = []
                return
            }

            items = try element.xmlChildren.map(Item.init(element:))
        }
    }
}

extension ComponentDefinition {
    public struct Override {
        public enum Message: String, CaseIterable {
            case willInit
            case didInit
            case willLoadView
            case didLoadView
            case willSetupConstraints
            case didSetupConstraints
            case willLayoutSubviews
            case didLayoutSubviews
            case willMoveToSuperview
            case didMoveToSuperview
            case willMoveToWindow
            case didMoveToWindow
            case didAddSubview
            case willRemoveSubview
            case layoutMarginsDidChange
            case safeAreaInsetsDidChange

            public var isAbstract: Bool {
                switch self {
                case .willLayoutSubviews, .didLayoutSubviews, .willMoveToSuperview, .didMoveToSuperview, .willMoveToWindow, .didMoveToWindow, .didAddSubview,
                     .willRemoveSubview, .layoutMarginsDidChange, .safeAreaInsetsDidChange:
                    return false
                case .willInit, .didInit, .willLoadView, .didLoadView, .willSetupConstraints, .didSetupConstraints:
                    return true
                }
            }

            public var methodId: String {
                switch self {
                case .willLayoutSubviews, .didLayoutSubviews:
                    return "layoutSubviews"
                case .willMoveToSuperview, .didMoveToSuperview, .willMoveToWindow, .didMoveToWindow, .didAddSubview,
                     .willRemoveSubview, .layoutMarginsDidChange, .safeAreaInsetsDidChange:
                    return rawValue
                case .willInit, .didInit, .willLoadView, .didLoadView, .willSetupConstraints, .didSetupConstraints:
                    return rawValue
                }
            }

            public var beforeSuper: Bool {
                switch self {
                case .willLayoutSubviews, .willMoveToSuperview, .willMoveToWindow, .willRemoveSubview, .willInit, .willLoadView, .willSetupConstraints:
                    return true
                case .didLayoutSubviews, .didMoveToSuperview, .didMoveToWindow, .didAddSubview, .layoutMarginsDidChange,
                     .safeAreaInsetsDidChange, .didInit, .didLoadView, .didSetupConstraints:
                    return false
                }
            }

            public var methodName: String {
                switch self {
                case .willLayoutSubviews, .didLayoutSubviews:
                    return "layoutSubviews"
                case .willMoveToSuperview, .willMoveToWindow:
                    return "willMove"
                case .didMoveToSuperview, .didMoveToWindow, .didAddSubview, .willRemoveSubview, .layoutMarginsDidChange,
                     .safeAreaInsetsDidChange, .willInit, .didInit, .willLoadView, .didLoadView, .willSetupConstraints, .didSetupConstraints:
                    return rawValue
                }
            }

            #if canImport(SwiftCodeGen)
            public var parameters: [MethodParameter] {
                switch self {
                case .willLayoutSubviews, .didLayoutSubviews, .didMoveToSuperview, .didMoveToWindow, .layoutMarginsDidChange, .safeAreaInsetsDidChange, .willInit, .didInit, .willLoadView, .didLoadView, .willSetupConstraints, .didSetupConstraints:

                    return []
                case .willMoveToSuperview:
                    return [
                        MethodParameter(label: "toSuperview", name: "newSuperview", type: "UIView?")
                    ]
                case .willMoveToWindow:
                    return [
                        MethodParameter(label: "toWindow", name: "newWindow", type: "UIWindow?")
                    ]
                case .didAddSubview, .willRemoveSubview:
                    return [
                        MethodParameter(label: "_", name: "subview", type: "UIView")
                    ]
                }
            }
            #endif
        }

        public var message: Message
        public var receiver: String

        public init(attribute: XMLAttribute) throws {
            guard let message = Message(rawValue: attribute.name) else {
                let supportedMessages = Message.allCases.map { $0.rawValue }.joined(separator: ", ")
                throw TokenizationError(message: "Unsupported override \(attribute.name). Supported are: [\(supportedMessages)].")
            }
            self.message = message

            // TODO Add more checks to determine the receiver's validity
            guard !attribute.text.isEmpty else {
                throw TokenizationError(message: "You have to specify receiver method for the override \(attribute.name).")
            }

            self.receiver = attribute.text
        }
    }
}
