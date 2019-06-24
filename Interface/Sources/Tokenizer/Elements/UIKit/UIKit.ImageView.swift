//
//  ImageView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//
#if canImport(UIKit)
    import UIKit
#endif

public class ImageView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.imageView.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIImageView()
    }
    #endif
}

public class ImageViewProperties: ViewProperties {
    public let image: StaticAssignablePropertyDescription<Image?>
    public let highlightedImage: StaticAssignablePropertyDescription<Image?>
    public let animationDuration: StaticAssignablePropertyDescription<Double>
    public let animationRepeatCount: StaticAssignablePropertyDescription<Int>
    public let isHighlighted: StaticAssignablePropertyDescription<Bool>
    public let adjustsImageWhenAncestorFocused: StaticAssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        image = configuration.property(name: "image")
        highlightedImage = configuration.property(name: "highlightedImage")
        animationDuration = configuration.property(name: "animationDuration")
        animationRepeatCount = configuration.property(name: "animationRepeatCount")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        adjustsImageWhenAncestorFocused = configuration.property(name: "adjustsImageWhenAncestorFocused")
        
        super.init(configuration: configuration)
    }
}
