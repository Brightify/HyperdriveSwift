//
//  AppKit.SplitView.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class SplitView: Container {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.splitView.allProperties
        }

        public override class func runtimeType() throws -> String {
            return "NSSplitView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            return RuntimeType(name: "NSSplitView", module: "AppKit")
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return NSSplitView()
        }
        #endif
    }

    public class SplitViewProperties: ViewProperties {
        public let isVertical: StaticAssignablePropertyDescription<Bool>
        public let dividerStyle: StaticAssignablePropertyDescription<SplitView.SplitViewDividerStyle>

        public required init(configuration: Configuration) {
            isVertical = configuration.property(name: "isVertical", key: "vertical", defaultValue: false)
            dividerStyle = configuration.property(name: "dividerStyle", defaultValue: .thick)

            super.init(configuration: configuration)
        }
    }
}

extension Module.AppKit.SplitView {
    public enum SplitViewDividerStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
        public static let enumName = "NSSplitView.DividerStyle"
        public static let typeFactory = TypeFactory()

        case thick
        case thin
        case paneSplitter
        
        public final class TypeFactory: EnumTypeFactory {
            public typealias BuildType = Module.AppKit.SplitView.SplitViewDividerStyle

            public init() { }
        }
    }
}

#if HyperdriveRuntime && canImport(AppKit)
import AppKit

extension Module.AppKit.SplitView.SplitViewDividerStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        let value: NSSplitView.DividerStyle
        switch self {
        case .thick:
            value = .thick
        case .thin:
            value = .thin
        case .paneSplitter:
            value = .paneSplitter
        }
        return value.rawValue
    }
}
#endif
