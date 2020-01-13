//
//  Container.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import HyperdriveInterface
#endif

extension Module.UIKit {
    public class Container: View, UIContainer {
        public var children: [UIElement]

        public var addSubviewMethod: String {
            return "addSubview"
        }

        #if canImport(UIKit)
        public func add(subview: UIView, toInstanceOfSelf: UIView) {
            toInstanceOfSelf.addSubview(subview)
        }
        #endif

        public required init(context: UIElementDeserializationContext, factory: UIElementFactory) throws {
            children = try context.element.xmlChildren.compactMap(context.deserialize(element:))

            try super.init(context: context, factory: factory)
        }

        public override init() {
            children = []

            super.init()
        }

        public override var requiredImports: Set<String> {
            return Set(arrayLiteral: "UIKit").union(children.flatMap { $0.requiredImports })
        }

        public class override func runtimeType() throws -> String {
            return "ContainerView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            return RuntimeType(name: "ContainerView", module: "Hyperdrive")
        }


        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var viewElement = super.serialize(context: context)

            // FIXME We should create an intermediate context
            viewElement.children.append(contentsOf: children.map { $0.serialize(context: context) })

            return viewElement
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return ContainerView()
        }
        #endif
    }
}
