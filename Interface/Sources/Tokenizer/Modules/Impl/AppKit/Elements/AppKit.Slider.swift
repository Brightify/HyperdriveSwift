//
//  AppKit.Slider.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/07/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

//#if GeneratingInterface || canImport(AppKit)
extension Module.AppKit {
    public class Slider: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.slider.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .macOS:
                return RuntimeType(name: "NSSlider", module: "AppKit")
            case .iOS, .tvOS:
                throw TokenizationError.unsupportedElementError(element: Slider.self)
            }
        }

        public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return try super.supportedActions(context: context) + [
//                ControlEventAction()
            ]
        }

//        #if HyperdriveRuntime && canImport(AppKit)
//        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView {
//            return NSSlider()
//        }
//        #endif
    }

    public class SliderProperties: ControlProperties {
        public let value: StaticAssignablePropertyDescription<Double>
        public let minimumValue: StaticAssignablePropertyDescription<Double>
        public let maximumValue: StaticAssignablePropertyDescription<Double>
        public let isContinuous: StaticAssignablePropertyDescription<Bool>
        public let trackFillColor: StaticAssignablePropertyDescription<UIColorPropertyType?>

        public required init(configuration: Configuration) {
            value = configuration.property(name: "value", swiftName: "doubleValue")
            minimumValue = configuration.property(name: "minimumValue", swiftName: "minValue")
            maximumValue = configuration.property(name: "maximumValue", swiftName: "maxValue", defaultValue: 1)
            isContinuous = configuration.property(name: "isContinuous", defaultValue: true)
            trackFillColor = configuration.property(name: "trackFillColor")

            super.init(configuration: configuration)
        }
    }
}
//#endif
