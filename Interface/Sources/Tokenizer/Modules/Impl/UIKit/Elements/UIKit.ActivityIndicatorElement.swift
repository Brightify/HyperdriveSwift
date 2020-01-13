//
//  ActivityIndicatorElement.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class ActivityIndicatorElement: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.activityIndicator.allProperties
        }

        public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
            return (.high, .high)
        }

        public class override func runtimeType() throws -> String {
            return "UIActivityIndicatorView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            return RuntimeType(name: "UIActivityIndicatorView", module: "UIKit")
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UIActivityIndicatorView()
        }
        #endif
    }

    public class ActivityIndicatorProperties: ViewProperties {
        public let color: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let hidesWhenStopped: StaticAssignablePropertyDescription<Bool>
        public let indicatorStyle: StaticAssignablePropertyDescription<ActivityIndicatorStyle>

        public required init(configuration: PropertyContainer.Configuration) {
            color = configuration.property(name: "color")
            hidesWhenStopped = configuration.property(name: "hidesWhenStopped", defaultValue: true)
            indicatorStyle = configuration.property(name: "indicatorStyle", swiftName: "style", key: "style", defaultValue: .white)

            super.init(configuration: configuration)
        }
    }
}
