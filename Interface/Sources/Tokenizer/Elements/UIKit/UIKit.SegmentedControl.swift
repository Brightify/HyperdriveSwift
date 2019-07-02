//
//  SegmentedControl.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct AnySupportedType: SupportedPropertyType {
    public let factory: SupportedTypeFactory
    public let requiresTheme: Bool

    #if canImport(SwiftCodeGen)
    public let generateValue: (SupportedPropertyTypeContext) -> Expression

    public init(factory: SupportedTypeFactory, requiresTheme: Bool = false, generateValue: @escaping (SupportedPropertyTypeContext) -> Expression) {

        self.factory = factory
        self.requiresTheme = requiresTheme
        self.generateValue = generateValue
    }

    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return generateValue(context)
    }
    #endif

    #if canImport(UIKit)
    public let resolveValue: (SupportedPropertyTypeContext) throws -> Any?

    public init(factory: SupportedTypeFactory, requiresTheme: Bool = false, resolveValue: @escaping (SupportedPropertyTypeContext) throws -> Any?) {

        self.factory = factory
        self.requiresTheme = requiresTheme
        self.resolveValue = resolveValue
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        fatalError("Not implemented")
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        return try resolveValue(context)
    }
    #endif
}

public struct AnySupportedTypeFactory: SupportedTypeFactory {
    public let isNullable: Bool
    public let xsdType: XSDType
    private let resolveRuntimeType: (RuntimePlatform) -> RuntimeType
    #if canImport(SwiftCodeGen)
    private let generateStateAccess: (String) -> Expression
    #endif

    #if canImport(SwiftCodeGen)
    public init(isNullable: Bool = false, xsdType: XSDType, resolveRuntimeType: @escaping (RuntimePlatform) -> RuntimeType, generateStateAccess: @escaping (String) -> Expression) {
        self.isNullable = isNullable
        self.xsdType = xsdType
        self.resolveRuntimeType = resolveRuntimeType
        self.generateStateAccess = generateStateAccess
    }
    #else
    public init(isNullable: Bool = false, xsdType: XSDType, resolveRuntimeType: @escaping (RuntimePlatform) -> RuntimeType) {
        self.isNullable = isNullable
        self.xsdType = xsdType
        self.resolveRuntimeType = resolveRuntimeType
    }
    #endif

    public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return resolveRuntimeType(platform)
    }

    #if canImport(SwiftCodeGen)
    public func generate(stateName: String) -> Expression {
        return generateStateAccess(stateName)
    }
    #endif
}

public struct AnyPropertyDescription: PropertyDescription {
    public let name: String
    public let namespace: [PropertyContainer.Namespace]
    public let anyDefaultValue: SupportedPropertyType
    public let anyTypeFactory: SupportedTypeFactory
}

public struct AnyAssignableProperty: Property {
    public var name: String
    public let attributeName: String
    public var namespace: [PropertyContainer.Namespace]
    public let key: String
    public let swiftName: String

    public let anyValue: AnyPropertyValue
    public let anyDescription: PropertyDescription

    #if canImport(SwiftCodeGen)
    public func application(context: PropertyContext) -> Expression {
        return anyValue.generate(context: context.child(for: anyValue))
    }

    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)

        return .assignment(target: .member(target: .constant(namespacedTarget), name: swiftName), expression: application(context: context))
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: anyValue.dematerialize(context: context.child(for: anyValue)))
    }
    #endif

    #if canImport(UIKit)
    public func apply(on object: AnyObject, context: PropertyContext) throws {
        let selector = Selector("set\(key.capitalizingFirstLetter()):")

        let target = try resolveTarget(for: object)

        guard target.responds(to: selector) else {
            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(key)` to set value `\(anyValue)`")
        }

        let resolvedValue = try anyValue.runtimeValue(context: context.child(for: anyValue))
        guard resolvedValue != nil || anyDescription.anyTypeFactory.isNullable else {
            throw LiveUIError(message: "!! Value `\(anyValue)` couldn't be resolved in runtime for key `\(key)`")
        }

        do {
            try catchException {
                _ = target.setValue(resolvedValue, forKey: key)
            }
        } catch {
            _ = target.perform(selector, with: resolvedValue)
        }

    }

    private func resolveTarget(for object: AnyObject) throws -> AnyObject {
        if namespace.isEmpty {
            return object
        } else {
            let keyPath = namespace.resolvedKeyPath
            guard let target = object.value(forKeyPath: keyPath) else {
                throw LiveUIError(message: "!! Object \(object) doesn't have keyPath \(keyPath) to resolve real target")
            }
            return target as AnyObject
        }
    }
    #endif
}

extension Module.UIKit {
    public class ControlEventAction: UIElementAction {
        public enum Event: String {
            case touchDown
            case touchDownRepeat
            case touchDragInside
            case touchDragOutside
            case touchDragEnter
            case touchDragExit
            case touchUpInside
            case touchUpOutside
            case touchCancel
            case valueChanged
            case primaryActionTriggered
            case editingDidBegin
            case editingChanged
            case editingDidEnd
            case editingDidEndOnExit

            static let allTouchEvents: Set<Event> = [
                .touchDown,
                .touchDownRepeat,
                .touchDragInside,
                .touchDragOutside,
                .touchDragEnter,
                .touchDragExit,
                .touchUpInside,
                .touchUpOutside,
                .touchCancel,
            ]
            static let allEditingEvents: Set<Event> = [
                .editingDidBegin,
                .editingChanged,
                .editingDidEnd,
                .editingDidEndOnExit,
            ]
            static let allEvents: Set<Event> = allTouchEvents.union(allEditingEvents)
        }

        public let primaryName: String
        public let aliases: Set<String>
        public let parameters: [Parameter]
        public let event: Event

        public init(name: String, aliases: Set<String> = [], parameters: [Parameter] = [], event: Event) {
            self.primaryName = name
            self.aliases = aliases
            self.parameters = parameters
            self.event = event
        }

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "events", value: .constant(".\(event.rawValue)")),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif

        public static let allTouchEvents: [ControlEventAction] = [
            ControlEventAction(name: "touchDown", event: .touchDown),
            ControlEventAction(name: "touchDownRepeat", event: .touchDownRepeat),
            ControlEventAction(name: "touchDragInside", event: .touchDragInside),
            ControlEventAction(name: "touchDragOutside", event: .touchDragOutside),
            ControlEventAction(name: "touchDragEnter", event: .touchDragEnter),
            ControlEventAction(name: "touchDragExit", event: .touchDragExit),
            ControlEventAction(name: "touchUpInside", aliases: ["tap"], event: .touchUpInside),
            ControlEventAction(name: "touchUpOutside", event: .touchUpOutside),
            ControlEventAction(name: "touchCancel", event: .touchCancel),
        ]

        public static let valueChanged = ControlEventAction(name: "valueChanged", aliases: ["value"], event: .valueChanged)
        public static let primaryActionTriggered = ControlEventAction(name: "primaryActionTriggered", aliases: ["primary"], event: .primaryActionTriggered)

        public static let allEditingEvents: [ControlEventAction] = [
            ControlEventAction(name: "editingDidBegin", event: .editingDidBegin),
            ControlEventAction(name: "editingChanged", aliases: ["textChanged"], event: .editingChanged),
            ControlEventAction(name: "editingDidEnd", event: .editingDidEnd),
            ControlEventAction(name: "editingDidEndOnExit", event: .editingDidEndOnExit),
        ]
    }

    public class SegmentControlSelectedAction: UIElementAction {
        public let primaryName = "selected"
        public let aliases: Set<String> = []
        public let parameters: [Parameter]
        private let factory: SupportedTypeFactory

        public init(factory: SupportedTypeFactory) {
            self.factory = factory

            parameters = [
                UIElementAction.Parameter(label: "segment", type: .propertyType(factory))
            ]
        }

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            let handlerWrapper = Closure(
                captures: [.weak(view)],
                block: [
                    .guard(conditions: [
                        ConditionExpression.conditionalUnwrap(isConstant: true, name: "view", expression: view),
                        ConditionExpression.conditionalUnwrap(isConstant: true, name: "selectedSegment", expression:
                            .invoke(target: .constant(factory.runtimeType(for: .iOS).name), arguments: [
                                MethodArgument(name: "rawValue", value: .constant("view.selectedSegmentIndex"))
                            ])),
                    ], else: [.return(expression: nil)]),
                    .expression(.invoke(target: .closure(handler.listener), arguments: [
                        MethodArgument(value: .constant("selectedSegment"))
                    ]))
                ])

            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "events", value: .constant(".valueChanged")),
                MethodArgument(name: "handler", value: .closure(handlerWrapper)),
            ]))
        }
        #endif
    }

    // TODO add a way of adding segments
    public class SegmentedControl: View {
        public struct Segment: SupportedPropertyType {
            public enum Content {
                case image(Image)
                case title(TransformedText)

                #if canImport(SwiftCodeGen)
                public func generate(context: DataContext) -> Expression {
                    switch self {
                    case .image(let image):
                        return image.generate(context: SupportedPropertyTypeContext(parentContext: context, value: .value(image)))
                    case .title(let text):
                        return text.generate(context: SupportedPropertyTypeContext(parentContext: context, value: .value(text)))
                    }
                }
                #endif
            }

            public var factory: SupportedTypeFactory

            public var index: Int
            public var name: String
            public var content: Content

            public let requiresTheme: Bool = false

            #if canImport(SwiftCodeGen)
            public func generate(context: SupportedPropertyTypeContext) -> Expression {
                return .constant(".\(name)")
            }
            #endif

            #if canImport(UIKit)
            public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
                return index
            }
            #endif

            public static func materialize(factory: SupportedTypeFactory, at index: Int, from element: XMLElement) throws -> Segment {
                let title = element.attribute(by: "title")
                let image = element.attribute(by: "image")

                let content: Content
                if title != nil && image != nil {
                    throw TokenizationError(message: "<segment> cannot have a title and an image at the same time!")
                } else if let title = title {
                    content = try .title(TransformedText.materialize(from: title.text))
                } else if let image = image {
                    content = try .image(Image.materialize(from: image.text))
                } else {
                    throw TokenizationError(message: "<segment> is required to have either a title or an image!")
                }

                return SegmentedControl.Segment(
                    factory: factory,
                    index: index,
                    name: element.name,
                    content: content)
            }
        }

        public override class var availableProperties: [PropertyDescription] {
            return Properties.segmentedControl.allProperties
        }

        public var segments: [Segment] = []

        public var selectedSegment: Property?

        #if canImport(SwiftCodeGen)
        public override var extraDeclarations: [Structure] {
            return [segmentsEnum] + super.extraDeclarations
        }

        public var segmentsEnum: Structure {
            return .enum(
                name: id.description.capitalizingFirstLetter() + "Segment",
                inheritances: ["Int"],
                cases: segments.map { Structure.EnumCase(name: $0.name) })
        }
        #endif

        private var segmentFactory: SupportedTypeFactory!

        public required init(context: UIElementDeserializationContext, factory: UIElementFactory) throws {
            try super.init(context: context, factory: factory)

            #if canImport(SwiftCodeGen)
            segmentFactory = AnySupportedTypeFactory(
                xsdType: .builtin(.string),
                resolveRuntimeType: { [id] _ in
                    RuntimeType(name: id.description.capitalizingFirstLetter() + "Segment")
                },
                generateStateAccess: { name in
                    Expression.member(target: .constant(name), name: "rawValue")
                })
            #else
            segmentFactory = AnySupportedTypeFactory(
                xsdType: .builtin(.string),
                resolveRuntimeType: { [id] _ in
                    RuntimeType(name: id.description.capitalizingFirstLetter() + "Segment")
                })
            #endif


            segments = try context.element.xmlChildren.enumerated().map { index, element in
                try Segment.materialize(factory: segmentFactory, at: index, from: element)
            }

            if let selectedSegmentAttribute = context.element.attribute(by: "selectedSegment") {
                let stringValue: AnyPropertyValue
                if selectedSegmentAttribute.text.starts(with: "$") {
                    stringValue = .state(String(selectedSegmentAttribute.text.dropFirst()), factory: segmentFactory)
                } else {
                    let segmentName = try String.typeFactory.materialize(from: selectedSegmentAttribute.text) as String
                    stringValue = .value(segments.firstIndex(where: { $0.name == segmentName })!)
                }

                let description = AnyPropertyDescription(
                    name: "selectedSegment",
                    namespace: [],
                    anyDefaultValue: segments.first!,
                    anyTypeFactory: segmentFactory)

                let selectedSegment = AnyAssignableProperty(
                    name: "selectedSegment",
                    attributeName: "selectedSegment",
                    namespace: [],
                    key: "selectedSegmentIndex",
                    swiftName: "selectedSegmentIndex",
                    anyValue: stringValue,
                    anyDescription: description)

                properties.append(selectedSegment)

                self.selectedSegment = selectedSegment
            } else {
                selectedSegment = nil
            }
        }

        public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return [
                SegmentControlSelectedAction(factory: segmentFactory),
            ]
        }

        #if canImport(SwiftCodeGen)
        public override func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression {
            return .invoke(target: .constant("UISegmentedControl"), arguments: [
                MethodArgument(name: "items", value: .arrayLiteral(items: segments.map {
                    $0.content.generate(context: context)
                }))
            ])
        }
        #endif

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UISegmentedControl()
        }
        #endif
    }

    public class SegmentedControlProperties: ControlProperties {
        public let selectedSegmentIndex: StaticAssignablePropertyDescription<Int>
        public let isMomentary: StaticAssignablePropertyDescription<Bool>
        public let apportionsSegmentWidthsByContent: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            selectedSegmentIndex = configuration.property(name: "selectedSegmentIndex")
            isMomentary = configuration.property(name: "isMomentary")
            apportionsSegmentWidthsByContent = configuration.property(name: "apportionsSegmentWidthsByContent")

            super.init(configuration: configuration)
        }
    }
}
