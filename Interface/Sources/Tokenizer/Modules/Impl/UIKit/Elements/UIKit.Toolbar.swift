//
//  Toolbar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class Toolbar: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.toolbar.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            switch platform {
            case .iOS:
                return RuntimeType(name: "UIToolbar", module: "UIKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: Toolbar.self)
            }
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            #if os(tvOS)
                fatalError("View not available in tvOS")
            #else
                return UIToolbar()
            #endif
        }
        #endif
    }

    public class ToolbarProperties: ViewProperties {
        public let isTranslucent: StaticAssignablePropertyDescription<Bool>
        public let barStyle: StaticAssignablePropertyDescription<BarStyle>
        public let barTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>

        public required init(configuration: Configuration) {
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
            barStyle = configuration.property(name: "barStyle", defaultValue: .default)
            barTintColor = configuration.property(name: "barTintColor")

            super.init(configuration: configuration)
        }
    }
}
