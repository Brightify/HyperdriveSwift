//
//  LayerProperties.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public class LayerProperties: PropertyContainer {
    public let cornerRadius: StaticAssignablePropertyDescription<Double>
    public let borderWidth: StaticAssignablePropertyDescription<Double>
    public let borderColor: StaticAssignablePropertyDescription<CGColorPropertyType?>
    public let opacity: StaticAssignablePropertyDescription<Double>
    public let isHidden: StaticAssignablePropertyDescription<Bool>
    public let masksToBounds: StaticAssignablePropertyDescription<Bool>
    public let isDoubleSided: StaticAssignablePropertyDescription<Bool>
    public let backgroundColor: StaticAssignablePropertyDescription<CGColorPropertyType?>
    public let shadowOpacity: StaticAssignablePropertyDescription<Double>
    public let shadowRadius: StaticAssignablePropertyDescription<Double>
    public let shadowColor: StaticAssignablePropertyDescription<CGColorPropertyType?>
    public let allowsEdgeAntialiasing: StaticAssignablePropertyDescription<Bool>
    public let allowsGroupOpacity: StaticAssignablePropertyDescription<Bool>
    public let isOpaque: StaticAssignablePropertyDescription<Bool>
    public let isGeometryFlipped: StaticAssignablePropertyDescription<Bool>
    public let shouldRasterize: StaticAssignablePropertyDescription<Bool>
    public let rasterizationScale: StaticAssignablePropertyDescription<Double>
    public let contentsFormat: StaticAssignablePropertyDescription<TransformedText>
    public let contentsScale: StaticAssignablePropertyDescription<Double>
    public let zPosition: StaticAssignablePropertyDescription<Double>
    public let name: StaticAssignablePropertyDescription<TransformedText?>
    public let contentsRect: StaticAssignablePropertyDescription<Rect>
    public let contentsCenter: StaticAssignablePropertyDescription<Rect>
    public let shadowOffset: StaticAssignablePropertyDescription<Size>
    public let frame: StaticAssignablePropertyDescription<Rect>
    public let bounds: StaticAssignablePropertyDescription<Rect>
    public let position: StaticAssignablePropertyDescription<Point>
    public let anchorPoint: StaticAssignablePropertyDescription<Point>
    public let maskedCorners: StaticAssignablePropertyDescription<CornerMask>
    // TODO: transform: CATransform3D
    
    public required init(configuration: Configuration) {
        cornerRadius = configuration.property(name: "cornerRadius")
        borderWidth = configuration.property(name: "borderWidth")
        borderColor = configuration.property(name: "borderColor", defaultValue: .black)
        opacity = configuration.property(name: "opacity", defaultValue: 1)
        isHidden = configuration.property(name: "isHidden", key: "hidden")
        masksToBounds = configuration.property(name: "masksToBounds")
        shadowOpacity = configuration.property(name: "shadowOpacity")
        shadowRadius = configuration.property(name: "shadowRadius", defaultValue: 3)
        shadowColor = configuration.property(name: "shadowColor", defaultValue: .black)
        allowsEdgeAntialiasing = configuration.property(name: "allowsEdgeAntialiasing")
        allowsGroupOpacity = configuration.property(name: "allowsGroupOpacity", defaultValue: true)
        isOpaque = configuration.property(name: "isOpaque", key: "opaque", defaultValue: true)
        shouldRasterize = configuration.property(name: "shouldRasterize")
        rasterizationScale = configuration.property(name: "rasterizationScale", defaultValue: 1)
        contentsFormat = configuration.property(name: "contentsFormat", defaultValue: .text("RGBA8Uint"))
        contentsScale = configuration.property(name: "contentsScale")
        zPosition = configuration.property(name: "zPosition")
        name = configuration.property(name: "name")
        contentsRect = configuration.property(name: "contentsRect", defaultValue: Rect(width: 1, height: 1))
        contentsCenter = configuration.property(name: "contentsCenter", defaultValue: Rect(width: 1, height: 1))
        shadowOffset = configuration.property(name: "shadowOffset", defaultValue: Size(width: 0, height: -3))
        frame = configuration.property(name: "frame", defaultValue: .zero)
        bounds = configuration.property(name: "bounds", defaultValue: .zero)
        position = configuration.property(name: "position", defaultValue: .zero)
        anchorPoint = configuration.property(name: "anchorPoint", defaultValue: Point(x: 0.5, y: 0.5))
        backgroundColor = configuration.property(name: "backgroundColor")
        isDoubleSided = configuration.property(name: "isDoubleSided", key: "doubleSided", defaultValue: true)
        isGeometryFlipped = configuration.property(name: "isGeometryFlipped", key: "geometryFlipped")
        maskedCorners = configuration.property(name: "maskedCorners", defaultValue: [])
        
        super.init(configuration: configuration)
    }
}
