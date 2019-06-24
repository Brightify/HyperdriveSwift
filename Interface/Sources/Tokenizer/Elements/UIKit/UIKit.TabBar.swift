//
//  TabBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class TabBar: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.tabBar.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UITabBar()
    }
    #endif
}

public class TabBarProperties: ViewProperties {
    public let isTranslucent: StaticAssignablePropertyDescription<Bool>
    public let barStyle: StaticAssignablePropertyDescription<BarStyle>
    public let barTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
    public let itemSpacing: StaticAssignablePropertyDescription<Double>
    public let itemWidth: StaticAssignablePropertyDescription<Double>
    public let backgroundImage: StaticAssignablePropertyDescription<Image?>
    public let shadowImage: StaticAssignablePropertyDescription<Image?>
    public let selectionIndicatorImage: StaticAssignablePropertyDescription<Image?>
    
    public required init(configuration: Configuration) {
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
        barStyle = configuration.property(name: "barStyle", defaultValue: .default)
        barTintColor = configuration.property(name: "barTintColor")
        itemSpacing = configuration.property(name: "itemSpacing")
        itemWidth = configuration.property(name: "itemWidth")
        backgroundImage = configuration.property(name: "backgroundImage")
        shadowImage = configuration.property(name: "shadowImage")
        selectionIndicatorImage = configuration.property(name: "selectionIndicatorImage")
        
        super.init(configuration: configuration)
    }
}
    
