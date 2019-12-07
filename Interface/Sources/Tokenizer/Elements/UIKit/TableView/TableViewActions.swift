//
//  TableViewActions.swift
//  tuistLiveInterface
//
//  Created by Tadeas Kriz on 07/12/2019.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Module.UIKit {
    public enum PlainTableViewAction: UIElementAction {
        case selected(cellType: String)
        case rowAction(cellType: String)
        case refresh

        public var primaryName: String {
            switch self {
            case .selected:
                return "selected"
            case .rowAction:
                return "rowAction"
            case .refresh:
                return "refresh"
            }
        }

        public var aliases: Set<String> {
            return []
        }

        public var parameters: [Parameter] {
            switch self {
            case .selected(let cellType):
                return [
                    (label: "state", type: SupportedActionType.elementReference(.init(name: "\(cellType).State"))),
                    (label: "indexPath", type: SupportedActionType.elementReference(.init(name: "IndexPath"))),
                ]
            case .rowAction(let cellType):
                return [
                    (label: "state", type: SupportedActionType.elementReference(.init(name: "\(cellType).State"))),
                    (label: "action", type: SupportedActionType.elementReference(.init(name: "\(cellType).Action"))),
                ]
            case .refresh:
                return []
            }
        }

        #if canImport(SwiftCodeGen)
        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
            let method: String
            switch self {
            case .selected:
                method = "bindSelected"
            case .rowAction:
                method = "bindRowAction"
            case .refresh:
                method = "refresh"
            }

            return .expression(.invoke(target: .constant("PlainTableViewObserver.\(method)"), arguments: [
                MethodArgument(name: "to", value: view),
                MethodArgument(name: "handler", value: .closure(handler.listener)),
            ]))
        }
        #endif

    }

//    public class ControlEventAction: UIElementAction {
//        public enum Event: String {
//            case touchDown
//            case touchDownRepeat
//            case touchDragInside
//            case touchDragOutside
//            case touchDragEnter
//            case touchDragExit
//            case touchUpInside
//            case touchUpOutside
//            case touchCancel
//            case valueChanged
//            case primaryActionTriggered
//            case editingDidBegin
//            case editingChanged
//            case editingDidEnd
//            case editingDidEndOnExit
//
//            static let allTouchEvents: Set<Event> = [
//                .touchDown,
//                .touchDownRepeat,
//                .touchDragInside,
//                .touchDragOutside,
//                .touchDragEnter,
//                .touchDragExit,
//                .touchUpInside,
//                .touchUpOutside,
//                .touchCancel,
//            ]
//            static let allEditingEvents: Set<Event> = [
//                .editingDidBegin,
//                .editingChanged,
//                .editingDidEnd,
//                .editingDidEndOnExit,
//            ]
//            static let allEvents: Set<Event> = allTouchEvents.union(allEditingEvents)
//        }
//
//        public let primaryName: String
//        public let aliases: Set<String>
//        public let parameters: [Parameter]
//        public let event: Event
//
//        public init(name: String, aliases: Set<String> = [], parameters: [Parameter] = [], event: Event) {
//            self.primaryName = name
//            self.aliases = aliases
//            self.parameters = parameters
//            self.event = event
//        }
//
//        #if canImport(SwiftCodeGen)
//        public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
//            return .expression(.invoke(target: .constant("ControlEventObserver.bind"), arguments: [
//                MethodArgument(name: "to", value: view),
//                MethodArgument(name: "events", value: .constant(".\(event.rawValue)")),
//                MethodArgument(name: "handler", value: .closure(handler.listener)),
//            ]))
//        }
//        #endif
//
//        public static let allTouchEvents: [ControlEventAction] = [
//            ControlEventAction(name: "touchDown", event: .touchDown),
//            ControlEventAction(name: "touchDownRepeat", event: .touchDownRepeat),
//            ControlEventAction(name: "touchDragInside", event: .touchDragInside),
//            ControlEventAction(name: "touchDragOutside", event: .touchDragOutside),
//            ControlEventAction(name: "touchDragEnter", event: .touchDragEnter),
//            ControlEventAction(name: "touchDragExit", event: .touchDragExit),
//            ControlEventAction(name: "touchUpInside", aliases: ["tap"], event: .touchUpInside),
//            ControlEventAction(name: "touchUpOutside", event: .touchUpOutside),
//            ControlEventAction(name: "touchCancel", event: .touchCancel),
//        ]
//
//        public static let valueChanged = ControlEventAction(name: "valueChanged", aliases: ["value"], event: .valueChanged)
//        public static let primaryActionTriggered = ControlEventAction(name: "primaryActionTriggered", aliases: ["primary"], event: .primaryActionTriggered)
//
//        public static let allEditingEvents: [ControlEventAction] = [
//            ControlEventAction(name: "editingDidBegin", event: .editingDidBegin),
//            ControlEventAction(name: "editingChanged", aliases: ["textChanged"], parameters: [(label: "text", type: .propertyType(String.typeFactory))], event: .editingChanged),
//            ControlEventAction(name: "editingDidEnd", event: .editingDidEnd),
//            ControlEventAction(name: "editingDidEndOnExit", event: .editingDidEndOnExit),
//        ]
//    }
}
