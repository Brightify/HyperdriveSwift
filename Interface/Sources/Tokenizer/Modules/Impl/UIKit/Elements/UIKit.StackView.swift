//
//  StackView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class StackView: Container {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.stackView.allProperties
        }

        public override var addSubviewMethod: String {
            return "addArrangedSubview"
        }

        public class override func runtimeType() throws -> String {
            return "UIStackView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            return RuntimeType(name: "UIStackView", module: "UIKit")
        }

        #if canImport(UIKit)
        public override func add(subview: UIView, toInstanceOfSelf: UIView) {
            guard let stackView = toInstanceOfSelf as? UIStackView else {
                return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
            }
            stackView.addArrangedSubview(subview)
        }
        #endif

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UIStackView()
        }
        #endif
    }

    public class StackViewProperties: ViewProperties {
        public let axis: StaticAssignablePropertyDescription<LayoutAxis>
        public let spacing: StaticAssignablePropertyDescription<Double>
        public let distribution: StaticAssignablePropertyDescription<StackView.LayoutDistribution>
        public let alignment: StaticAssignablePropertyDescription<LayoutAlignment>
        public let isBaselineRelativeArrangement: StaticAssignablePropertyDescription<Bool>
        public let isLayoutMarginsRelativeArrangement: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            axis = configuration.property(name: "axis", defaultValue: .horizontal)
            spacing = configuration.property(name: "spacing")
            distribution = configuration.property(name: "distribution", defaultValue: .fill)
            alignment = configuration.property(name: "alignment", defaultValue: .fill)
            isBaselineRelativeArrangement = configuration.property(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement")
            isLayoutMarginsRelativeArrangement = configuration.property(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement")

            super.init(configuration: configuration)
        }
    }
}

extension Module.UIKit.StackView {
    public enum LayoutDistribution: String, EnumPropertyType, AttributeSupportedPropertyType {
        public static let enumName = "UIStackView.Distribution"
        public static let typeFactory = TypeFactory()

        case fill
        case fillEqually
        case fillProportionally
        case equalCentering
        case equalSpacing

        public final class TypeFactory: EnumTypeFactory {
            public typealias BuildType = LayoutDistribution

            public init() { }
        }
    }
}

#if canImport(UIKit)
extension Module.UIKit.StackView.LayoutDistribution {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .equalCentering:
            return UIStackView.Distribution.equalCentering.rawValue
        case .equalSpacing:
            return UIStackView.Distribution.equalSpacing.rawValue
        case .fill:
            return UIStackView.Distribution.fill.rawValue
        case .fillEqually:
            return UIStackView.Distribution.fillEqually.rawValue
        case .fillProportionally:
            return UIStackView.Distribution.fillProportionally.rawValue
        }
    }
}
#endif

public enum LayoutAlignment: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIStackView.Alignment"
    public static let typeFactory = TypeFactory()

    case fill
    case firstBaseline
    case lastBaseline
    case leading
    case trailing
    case center

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = LayoutAlignment

        public init() { }
    }
}

#if canImport(UIKit)
extension LayoutAlignment {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .center:
            return UIStackView.Alignment.center.rawValue
        case .fill:
            return UIStackView.Alignment.fill.rawValue
        case .firstBaseline:
            return UIStackView.Alignment.firstBaseline.rawValue
        case .lastBaseline:
            return UIStackView.Alignment.lastBaseline.rawValue
        case .leading:
            return UIStackView.Alignment.leading.rawValue
        case .trailing:
            return UIStackView.Alignment.trailing.rawValue
        }
    }
}
#endif
