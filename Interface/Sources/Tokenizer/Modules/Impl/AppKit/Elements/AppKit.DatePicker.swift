//
//  AppKit.DatePicker.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class DatePicker: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.datePicker.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            switch platform {
            case .iOS:
                return RuntimeType(name: "UIDatePicker", module: "AppKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: DatePicker.self)
            }
        }

//        #if canImport(UIKit)
//        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
//            
//            #if os(tvOS)
//            throw TokenizationError.unsupportedElementError(element: DatePicker.self)
//            #else
//            return UIDatePicker()
//            #endif
//        }
//        #endif
    }

    public class DatePickerProperties: ControlProperties {
        public let backgroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
//        public let mode: StaticAssignablePropertyDescription<DatePickerMode>

        public required init(configuration: PropertyContainer.Configuration) {
            backgroundColor = configuration.property(name: "backgroundColor")
            // single x range
//            mode = configuration.property(name: "mode", swiftName: "datePickerMode", key: "datePickerMode", defaultValue: .dateAndTime)
            super.init(configuration: configuration)
        }
    }
}
