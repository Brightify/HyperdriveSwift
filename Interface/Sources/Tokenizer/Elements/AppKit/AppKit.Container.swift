//
//  AppKit.Container.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class Container: View, UIContainer {
        public var children: [UIElement]

        public var addSubviewMethod: String {
            return "addSubview"
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public func add(subview: NSView, toInstanceOfSelf: NSView) {
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
            return Set(arrayLiteral: "AppKit").union(children.flatMap { $0.requiredImports })
        }

        public class override func runtimeType() throws -> String {
            return "NSView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            return RuntimeType(name: "NSView", module: "AppKit")
        }


        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var viewElement = super.serialize(context: context)

            // FIXME We should create an intermediate context
            viewElement.children.append(contentsOf: children.map { $0.serialize(context: context) })

            return viewElement
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return NSView()
        }
        #endif
    }
}
