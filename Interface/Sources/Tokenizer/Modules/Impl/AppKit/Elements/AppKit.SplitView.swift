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
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
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
    public enum SplitViewDividerStyle: String, EnumPropertyType {
        public static let enumName = "NSSplitView.DividerStyle"
        public static let typeFactory = EnumTypeFactory<SplitViewDividerStyle>()

        case thick
        case thin
        case paneSplitter
    }
}

#if !GeneratingInterface && canImport(AppKit)
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
#elseif !GeneratingInterface
extension Module.AppKit.SplitView.SplitViewDividerStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        fatalError("Not supported")
    }
}
#endif
