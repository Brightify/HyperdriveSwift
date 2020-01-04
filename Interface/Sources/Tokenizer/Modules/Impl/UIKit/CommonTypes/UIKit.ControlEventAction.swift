//
//  UIKit.ControlEventAction.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

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
            ControlEventAction(name: "editingDidBegin", parameters: [(label: "text", type: .propertyType(String?.typeFactory))], event: .editingDidBegin),
            ControlEventAction(name: "editingChanged", aliases: ["textChanged"], parameters: [(label: "text", type: .propertyType(String?.typeFactory))], event: .editingChanged),
            ControlEventAction(name: "editingDidEnd", parameters: [(label: "text", type: .propertyType(String?.typeFactory))], event: .editingDidEnd),
            ControlEventAction(name: "editingDidEndOnExit", parameters: [(label: "text", type: .propertyType(String?.typeFactory))], event: .editingDidEndOnExit),
        ]
    }
}
