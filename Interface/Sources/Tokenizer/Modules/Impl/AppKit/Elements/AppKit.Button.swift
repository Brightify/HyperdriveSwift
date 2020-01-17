//
//  AppKit.Button.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 26/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public enum ButtonType: String, EnumPropertyType {
        public static let enumName = "NSButton.ButtonType"
        public static let typeFactory = EnumTypeFactory<ButtonType>()

        case accelerator
        case momentaryChange
        case momentaryLight
        case momentaryPushIn
        case multiLevelAccelerator
        case onOff
        case pushOnPushOff
        case radio
        case `switch`
        case toggle
    }

    public class Button: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.button.allProperties
        }

        public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return [ControlEventAction(
                primaryName: "click",
                aliases: ["tap"],
                parameters: [])]
        }

//        #if canImport(AppKit)
//        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
//            return NSButton()
//        }
//        #endif
    }

    public class ButtonProperties: ControlProperties {
        public let title: StaticControlStatePropertyDescription<TransformedText?>
        public let image: StaticControlStatePropertyDescription<Image?>
        public let attributedTitle: StaticElementControlStatePropertyDescription<Module.Foundation.AttributedText?>

        public required init(configuration: PropertyContainer.Configuration) {
            title = configuration.property(name: "title")
            image = configuration.property(name: "image")
            attributedTitle = configuration.property(name: "attributedTitle")

            super.init(configuration: configuration)
        }
    }

    // FIXME maybe create Control Element and move it there
    public class ControlProperties: ViewProperties {
        public let state: StaticAssignablePropertyDescription<NSControlStateValue>
        public let allowsMixedState: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: PropertyContainer.Configuration) {
            state = configuration.property(name: "state", defaultValue: .off)
            allowsMixedState = configuration.property(name: "allowsMixedState", defaultValue: false)

            super.init(configuration: configuration)
        }
    }

    public enum NSControlStateValue: String, EnumPropertyType {
        public static let enumName = "NSControl.StateValue"
        public static let typeFactory = EnumTypeFactory<NSControlStateValue>()

        case mixed
        case off
        case on
    }
}

#if HyperdriveRuntime && canImport(AppKit)
import AppKit

extension Module.AppKit.ButtonType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .accelerator:
            return NSButton.ButtonType.accelerator.rawValue
        case .momentaryChange:
            return NSButton.ButtonType.momentaryChange.rawValue
        case .momentaryLight:
            return NSButton.ButtonType.momentaryLight.rawValue
        case .momentaryPushIn:
            return NSButton.ButtonType.momentaryPushIn.rawValue
        case .multiLevelAccelerator:
            return NSButton.ButtonType.multiLevelAccelerator.rawValue
        case .onOff:
            return NSButton.ButtonType.onOff.rawValue
        case .pushOnPushOff:
            return NSButton.ButtonType.pushOnPushOff.rawValue
        case .radio:
            return NSButton.ButtonType.radio.rawValue
        case .`switch`:
            return NSButton.ButtonType.switch.rawValue
        case .toggle:
            return NSButton.ButtonType.toggle.rawValue
        }
    }
}

extension Module.AppKit.NSControlStateValue {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .mixed:
            return NSControl.StateValue.mixed.rawValue
        case .off:
            return NSControl.StateValue.off.rawValue
        case .on:
            return NSControl.StateValue.on.rawValue
        }
    }
}
#elseif !GeneratingInterface
extension Module.AppKit.ButtonType {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        fatalError("Not supported")
    }
}

extension Module.AppKit.NSControlStateValue {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        fatalError("Not supported")
    }
}
#endif
