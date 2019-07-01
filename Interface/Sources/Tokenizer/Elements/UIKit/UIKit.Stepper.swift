//
//  Stepper.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class Stepper: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.stepper.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .iOS:
                return RuntimeType(name: "UIStepper", module: "UIKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: Stepper.self)
            }
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            #if os(tvOS)
                throw TokenizationError.unsupportedElementError(element: Stepper.self)
            #else
                return UIStepper()
            #endif
        }
        #endif
    }

    public class StepperProperties: ControlProperties {
        public let value: StaticAssignablePropertyDescription<Double>
        public let minimumValue: StaticAssignablePropertyDescription<Double>
        public let maximumValue: StaticAssignablePropertyDescription<Double>
        public let stepValue: StaticAssignablePropertyDescription<Double>
        public let isContinuous: StaticAssignablePropertyDescription<Bool>
        public let autorepeat: StaticAssignablePropertyDescription<Bool>
        public let wraps: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            value = configuration.property(name: "value")
            minimumValue = configuration.property(name: "minimumValue")
            maximumValue = configuration.property(name: "maximumValue")
            stepValue = configuration.property(name: "stepValue")
            isContinuous = configuration.property(name: "isContinuous", key: "continuous")
            autorepeat = configuration.property(name: "autorepeat")
            wraps = configuration.property(name: "wraps")

            super.init(configuration: configuration)
        }
    }
}
