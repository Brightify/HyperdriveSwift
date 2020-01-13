//
//  Switch.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class Switch: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.switch.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            switch platform {
            case .iOS:
                return RuntimeType(name: "UISwitch", module: "UIKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: Switch.self)
            }
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            #if os(tvOS)
                throw TokenizationError.unsupportedElementError(element: Switch.self)
            #else
                return UISwitch()
            #endif
        }
        #endif
    }

    public class SwitchProperties: ControlProperties {
        public let isOn: StaticAssignablePropertyDescription<Bool>
        public let onTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let thumbTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let onImage: StaticAssignablePropertyDescription<Image?>
        public let offImage: StaticAssignablePropertyDescription<Image?>

        public required init(configuration: Configuration) {
            isOn = configuration.property(name: "isOn")
            onTintColor = configuration.property(name: "onTintColor")
            thumbTintColor = configuration.property(name: "thumbTintColor")
            onImage = configuration.property(name: "onImage")
            offImage = configuration.property(name: "offImage")

            super.init(configuration: configuration)
        }
    }
}
