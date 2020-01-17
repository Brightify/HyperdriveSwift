//
//  AppKit.StackView.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 02/07/2019.
//

// Used in both the view itself and its properties below it.
#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class StackView: Container {
//        public override class var availableProperties: [PropertyDescription] {
//            return Properties.stackView.allProperties
//        }

        public override var addSubviewMethod: String {
            return "addArrangedSubview"
        }

        public class override func runtimeType() throws -> String {
            return "NSStackView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            return RuntimeType(name: "NSStackView", module: "AppKit")
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func add(subview: NSView, toInstanceOfSelf: NSView) {
            guard let stackView = toInstanceOfSelf as? NSStackView else {
                return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
            }
            stackView.addArrangedSubview(subview)
        }
        #endif

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return NSStackView()
        }
        #endif
    }

    public class StackViewProperties: ViewProperties {
        public let axis: StaticAssignablePropertyDescription<StackView.UserInterfaceLayoutOrientation>
        public let spacing: StaticAssignablePropertyDescription<Double>
        public let distribution: StaticAssignablePropertyDescription<StackView.LayoutDistribution>
        public let alignment: StaticAssignablePropertyDescription<LayoutAlignment>
        public let isBaselineRelativeArrangement: StaticAssignablePropertyDescription<Bool>
        public let isLayoutMarginsRelativeArrangement: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            axis = configuration.property(name: "axis", swiftName: "orientation", defaultValue: .horizontal)
            spacing = configuration.property(name: "spacing")
            distribution = configuration.property(name: "distribution", defaultValue: .gravityAreas)
            alignment = configuration.property(name: "alignment", defaultValue: .fill)
            isBaselineRelativeArrangement = configuration.property(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement")
            isLayoutMarginsRelativeArrangement = configuration.property(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement")

            super.init(configuration: configuration)
        }
    }
}

// MARK: - UserInterfaceLayoutOrientation
extension Module.AppKit.StackView {
    public enum UserInterfaceLayoutOrientation: String, EnumPropertyType {
        public static let enumName = "NSUserInterfaceLayoutOrientation"
        public static let typeFactory = EnumTypeFactory<UserInterfaceLayoutOrientation>()

        case vertical
        case horizontal
    }
}

#if HyperdriveRuntime && canImport(AppKit)
extension Module.AppKit.StackView.UserInterfaceLayoutOrientation {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .vertical:
            return NSUserInterfaceLayoutOrientation.vertical.rawValue
        case .horizontal:
            return NSUserInterfaceLayoutOrientation.horizontal.rawValue
        }
    }
}
#elseif !GeneratingInterface
extension Module.AppKit.StackView.UserInterfaceLayoutOrientation {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        fatalError("Not supported")
    }
}
#endif

// MARK: - UserInterfaceLayoutOrientation
extension Module.AppKit.StackView {
    public enum LayoutDistribution: String, EnumPropertyType {
        public static let enumName = "NSStackView.Distribution"
        public static let typeFactory = EnumTypeFactory<LayoutDistribution>()

        case fill
        case fillEqually
        case fillProportionally
        case equalCentering
        case equalSpacing
        case gravityAreas
    }
}

#if HyperdriveRuntime
extension Module.AppKit.StackView.LayoutDistribution {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        #if canImport(AppKit)
        switch self {
        case .equalCentering:
            return NSStackView.Distribution.equalCentering.rawValue
        case .equalSpacing:
            return NSStackView.Distribution.equalSpacing.rawValue
        case .fill:
            return NSStackView.Distribution.fill.rawValue
        case .fillEqually:
            return NSStackView.Distribution.fillEqually.rawValue
        case .fillProportionally:
            return NSStackView.Distribution.fillProportionally.rawValue
        case .gravityAreas:
            return NSStackView.Distribution.gravityAreas.rawValue
        }
        #else
        fatalError("Not supported on this platform!")
        #endif
    }
}
#endif

// MARK: - LayoutAlignment
extension Module.AppKit.StackView {
    public enum LayoutAlignment: String, EnumPropertyType {
        public static let enumName = "NSStackView.Alignment"
        public static let typeFactory = EnumTypeFactory<LayoutAlignment>()

        case fill
        case firstBaseline
        case lastBaseline
        case leading
        case trailing
        case center
    }
}

#if !GeneratingInterface && canImport(AppKit)
extension Module.AppKit.StackView.LayoutAlignment {
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        switch self {
        case .center:
            return NSStackView.Alignment.center.rawValue
        case .fill:
            return NSStackView.Alignment.fill.rawValue
        case .firstBaseline:
            return NSStackView.Alignment.firstBaseline.rawValue
        case .lastBaseline:
            return NSStackView.Alignment.lastBaseline.rawValue
        case .leading:
            return NSStackView.Alignment.leading.rawValue
        case .trailing:
            return NSStackView.Alignment.trailing.rawValue
        }
    }
}
#elseif !GeneratingInterface
extension Module.AppKit.StackView.LayoutAlignment {
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        fatalError("Not supported!")
    }
}
#endif
