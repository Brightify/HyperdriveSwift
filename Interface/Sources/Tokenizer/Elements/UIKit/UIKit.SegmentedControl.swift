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

extension Module.UIKit {
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

    public class SegmentControlSelectedAction: UIElementAction {
        public let primaryName = "selected"
        public let aliases: Set<String> = []
        public let parameters: [Parameter]
        private let factory: SupportedTypeFactory

        public init(factory: SupportedTypeFactory) {
            self.factory = factory

            parameters = [
                Parameter(label: "segment", type: .propertyType(factory))
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
}
