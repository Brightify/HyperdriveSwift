//
//  Slider.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class Slider: View {
        public static let valueChanged = ControlEventAction(
            name: "valueChanged",
            aliases: ["value"],
            parameters: [(label: "value", type: .propertyType(Float.typeFactory))],
            event: .valueChanged)

        public override class var availableProperties: [PropertyDescription] {
            return Properties.slider.allProperties
        }

        public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return try super.supportedActions(context: context) + [Self.valueChanged]
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            switch platform {
            case .iOS:
                return RuntimeType(name: "UISlider", module: "UIKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: Slider.self)
            }
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            #if os(tvOS)
                throw TokenizationError.unsupportedElementError(element: Slider.self)
            #else
                return UISlider()
            #endif
        }
        #endif
    }

    public class SliderProperties: ControlProperties {
        public let value: StaticAssignablePropertyDescription<Float>
        public let minimumValue: StaticAssignablePropertyDescription<Float>
        public let maximumValue: StaticAssignablePropertyDescription<Float>
        public let isContinuous: StaticAssignablePropertyDescription<Bool>
        public let minimumValueImage: StaticAssignablePropertyDescription<Image?>
        public let maximumValueImage: StaticAssignablePropertyDescription<Image?>
        public let minimumTrackTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let minimumTrackImage: StaticControlStatePropertyDescription<Image?>
        public let maximumTrackTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let maximumTrackImage: StaticControlStatePropertyDescription<Image?>
        public let thumbTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let thumbImage: StaticControlStatePropertyDescription<Image?>

        public required init(configuration: Configuration) {
            value = configuration.property(name: "value")
            minimumValue = configuration.property(name: "minimumValue")
            maximumValue = configuration.property(name: "maximumValue", defaultValue: 1)
            isContinuous = configuration.property(name: "isContinuous", defaultValue: true)
            minimumValueImage = configuration.property(name: "minimumValueImage")
            maximumValueImage = configuration.property(name: "maximumValueImage")
            minimumTrackTintColor = configuration.property(name: "minimumTrackTintColor")
            minimumTrackImage = configuration.property(name: "minimumTrackImage")
            maximumTrackTintColor = configuration.property(name: "maximumTrackTintColor")
            maximumTrackImage = configuration.property(name: "maximumTrackImage")
            thumbTintColor = configuration.property(name: "thumbTintColor")
            thumbImage = configuration.property(name: "thumbImage")

            super.init(configuration: configuration)
        }
    }
}
