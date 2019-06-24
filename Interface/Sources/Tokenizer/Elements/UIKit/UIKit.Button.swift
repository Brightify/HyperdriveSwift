//
//  Button.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class Button: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.button.allProperties
    }

    public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
        return ControlEventAction.allTouchEvents
    }
    
    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIButton()
    }
    #endif
}

public class ButtonProperties: ControlProperties {
    public let title: StaticControlStatePropertyDescription<TransformedText?>
    public let titleColor: StaticControlStatePropertyDescription<UIColorPropertyType?>
    public let backgroundColorForState: StaticControlStatePropertyDescription<UIColorPropertyType?>
    public let titleShadowColor: StaticControlStatePropertyDescription<UIColorPropertyType?>
    public let image: StaticControlStatePropertyDescription<Image?>
    public let backgroundImage: StaticControlStatePropertyDescription<Image?>
    public let reversesTitleShadowWhenHighlighted: StaticAssignablePropertyDescription<Bool>
    public let adjustsImageWhenHighlighted: StaticAssignablePropertyDescription<Bool>
    public let adjustsImageWhenDisabled: StaticAssignablePropertyDescription<Bool>
    public let showsTouchWhenHighlighted: StaticAssignablePropertyDescription<Bool>
    public let contentEdgeInsets: StaticAssignablePropertyDescription<EdgeInsets>
    public let titleEdgeInsets: StaticAssignablePropertyDescription<EdgeInsets>
    public let imageEdgeInsets: StaticAssignablePropertyDescription<EdgeInsets>
    public let attributedTitle: StaticElementControlStatePropertyDescription<AttributedText?>
    
    public let titleLabel: LabelProperties
    public let imageView: ImageViewProperties
    
    public required init(configuration: PropertyContainer.Configuration) {
        title = configuration.property(name: "title")
        titleColor = configuration.property(name: "titleColor")
        backgroundColorForState = configuration.property(name: "backgroundColor")
        titleShadowColor = configuration.property(name: "titleShadowColor")
        image = configuration.property(name: "image")
        backgroundImage = configuration.property(name: "backgroundImage")
        reversesTitleShadowWhenHighlighted = configuration.property(name: "reversesTitleShadowWhenHighlighted")
        adjustsImageWhenHighlighted = configuration.property(name: "adjustsImageWhenHighlighted")
        adjustsImageWhenDisabled = configuration.property(name: "adjustsImageWhenDisabled")
        showsTouchWhenHighlighted = configuration.property(name: "showsTouchWhenHighlighted")
        contentEdgeInsets = configuration.property(name: "contentEdgeInsets")
        titleEdgeInsets = configuration.property(name: "titleEdgeInsets")
        imageEdgeInsets = configuration.property(name: "imageEdgeInsets")
        attributedTitle = configuration.property(name: "attributedTitle")
        titleLabel = configuration.namespaced(in: "titleLabel", optional: true, LabelProperties.self)
        imageView = configuration.namespaced(in: "imageView", optional: true, ImageViewProperties.self)
        
        super.init(configuration: configuration)
    }
}

// FIXME maybe create Control Element and move it there
public class ControlProperties: ViewProperties {
    public let isEnabled: StaticAssignablePropertyDescription<Bool>
    public let isSelected: StaticAssignablePropertyDescription<Bool>
    public let isHighlighted: StaticAssignablePropertyDescription<Bool>
    public let contentVerticalAlignment: StaticAssignablePropertyDescription<ControlContentVerticalAlignment>
    public let contentHorizontalAlignment: StaticAssignablePropertyDescription<ControlContentHorizontalAlignment>
    
    public required init(configuration: PropertyContainer.Configuration) {
        isEnabled = configuration.property(name: "isEnabled", key: "enabled", defaultValue: true)
        isSelected = configuration.property(name: "isSelected", key: "selected")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        contentVerticalAlignment = configuration.property(name: "contentVerticalAlignment", defaultValue: .top)
        contentHorizontalAlignment = configuration.property(name: "contentHorizontalAlignment", defaultValue: .center)
        
        super.init(configuration: configuration)
    }
}
