//
//  Slider.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class Slider: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.slider.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
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
        public let value: StaticAssignablePropertyDescription<Double>
        public let minimumValue: StaticAssignablePropertyDescription<Double>
        public let maximumValue: StaticAssignablePropertyDescription<Double>
        public let isContinuous: StaticAssignablePropertyDescription<Bool>
        public let minimumValueImage: StaticAssignablePropertyDescription<Image?>
        public let maximumValueImage: StaticAssignablePropertyDescription<Image?>
        public let minimumTrackTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let currentMinimumTrackImage: StaticAssignablePropertyDescription<Image?>
        public let maximumTrackTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let currentMaximumTrackImage: StaticAssignablePropertyDescription<Image?>
        public let thumbTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let currentThumbImage: StaticAssignablePropertyDescription<Image?>

        public required init(configuration: Configuration) {
            value = configuration.property(name: "value")
            minimumValue = configuration.property(name: "minimumValue")
            maximumValue = configuration.property(name: "maximumValue", defaultValue: 1)
            isContinuous = configuration.property(name: "isContinuous", defaultValue: true)
            minimumValueImage = configuration.property(name: "minimumValueImage")
            maximumValueImage = configuration.property(name: "maximumValueImage")
            minimumTrackTintColor = configuration.property(name: "minimumTrackTintColor")
            currentMinimumTrackImage = configuration.property(name: "currentMinimumTrackImage")
            maximumTrackTintColor = configuration.property(name: "maximumTrackTintColor")
            currentMaximumTrackImage = configuration.property(name: "currentMaximumTrackImage")
            thumbTintColor = configuration.property(name: "thumbTintColor")
            currentThumbImage = configuration.property(name: "currentThumbImage")

            super.init(configuration: configuration)
        }
    }
}
