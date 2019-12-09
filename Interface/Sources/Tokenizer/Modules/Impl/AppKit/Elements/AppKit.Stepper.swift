//
//  AppKit.Stepper.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class Stepper: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.stepper.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .macOS:
                return RuntimeType(name: "NSStepper", module: "AppKit")
            case .iOS, .tvOS:
                throw TokenizationError.unsupportedElementError(element: Stepper.self)
            }
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView {
            return NSStepper()
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
            value = configuration.property(name: "value", swiftName: "integerValue")
            minimumValue = configuration.property(name: "minimumValue", swiftName: "minValue")
            maximumValue = configuration.property(name: "maximumValue", swiftName: "maxValue")
            stepValue = configuration.property(name: "stepValue", swiftName: "increment")
            isContinuous = configuration.property(name: "isContinuous", key: "continuous")
            autorepeat = configuration.property(name: "autorepeat")
            wraps = configuration.property(name: "wraps", swiftName: "valueWraps")

            super.init(configuration: configuration)
        }
    }
}
