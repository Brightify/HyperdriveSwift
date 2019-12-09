//
//  NavigationBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class NavigationBar: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.navigationBar.allProperties
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UINavigationBar()
        }
        #endif
    }

    public class NavigationBarProperties: ViewProperties {
        public let barTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let backIndicatorImage: StaticAssignablePropertyDescription<Image?>
        public let backIndicatorTransitionMaskImage: StaticAssignablePropertyDescription<Image?>
        public let shadowImage: StaticAssignablePropertyDescription<Image?>
        public let isTranslucent: StaticAssignablePropertyDescription<Bool>
        public let barStyle: StaticAssignablePropertyDescription<BarStyle>

        public required init(configuration: Configuration) {
            barTintColor = configuration.property(name: "barTintColor")
            backIndicatorImage = configuration.property(name: "backIndicatorImage")
            backIndicatorTransitionMaskImage = configuration.property(name: "backIndicatorTransitionMaskImage")
            shadowImage = configuration.property(name: "shadowImage")
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
            barStyle = configuration.property(name: "barStyle", defaultValue: .default)

            super.init(configuration: configuration)
        }
    }
}
