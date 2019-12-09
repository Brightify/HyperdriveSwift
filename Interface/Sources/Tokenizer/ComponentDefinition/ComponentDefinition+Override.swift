//
//  ComponentDefinition+Override.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

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
