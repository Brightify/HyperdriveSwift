//
//  TableView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class TableView: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.tableView.allProperties
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UITableView()
        }
        #endif
    }

    public enum RowHeight: TypedSupportedType, HasStaticTypeFactory {
        private static let automaticIdentifier = "auto"
        public static let typeFactory = TypeFactory()

        case value(Float)
        case automatic

        #if canImport(SwiftCodeGen)
        public func generate(context: SupportedPropertyTypeContext) -> Expression {
            switch self {
            case .value(let value):
                return value.generate(context: context.child(for: value))
            case .automatic:
                return .constant("UITableView.automaticDimension")
            }
        }
        #endif

        #if SanAndreas
        public func dematerialize(context: SupportedPropertyTypeContext) -> String {
            switch self {
            case .value(let value):
                return value.dematerialize(context: context.child(for: value))
            case .automatic:
                return RowHeight.automaticIdentifier
            }
        }
        #endif

        #if canImport(UIKit)
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .value(let value):
                return value
            case .automatic:
                return UITableView.automaticDimension
            }
        }
        #endif
    }

    public class TableViewProperties: ViewProperties {
        public let rowHeight: StaticAssignablePropertyDescription<RowHeight>
        public let separatorStyle: StaticAssignablePropertyDescription<TableViewCellSeparatorStyle>
        public let separatorColor: StaticAssignablePropertyDescription<UIColorPropertyType>
        public let separatorEffect: StaticAssignablePropertyDescription<VisualEffect?>
        public let separatorInset: StaticAssignablePropertyDescription<EdgeInsets>
        public let separatorInsetReference: StaticAssignablePropertyDescription<TableViewCellSeparatorInsetReference>
        public let cellLayoutMarginsFollowReadableWidth: StaticAssignablePropertyDescription<Bool>
        public let sectionHeaderHeight: StaticAssignablePropertyDescription<Double>
        public let sectionFooterHeight: StaticAssignablePropertyDescription<Double>
        public let estimatedRowHeight: StaticAssignablePropertyDescription<Double>
        public let estimatedSectionHeaderHeight: StaticAssignablePropertyDescription<Double>
        public let estimatedSectionFooterHeight: StaticAssignablePropertyDescription<Double>
        public let allowsSelection: StaticAssignablePropertyDescription<Bool>
        public let allowsMultipleSelection: StaticAssignablePropertyDescription<Bool>
        public let allowsSelectionDuringEditing: StaticAssignablePropertyDescription<Bool>
        public let allowsMultipleSelectionDuringEditing: StaticAssignablePropertyDescription<Bool>
        public let dragInteractionEnabled: StaticAssignablePropertyDescription<Bool>
        public let isEditing: StaticAssignablePropertyDescription<Bool>
        public let sectionIndexMinimumDisplayRowCount: StaticAssignablePropertyDescription<Int>
        public let sectionIndexColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let sectionIndexBackgroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let sectionIndexTrackingBackgroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let remembersLastFocusedIndexPath: StaticAssignablePropertyDescription<Bool>
        public let insetsContentViewsToSafeArea: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            rowHeight = configuration.property(name: "rowHeight", defaultValue: .automatic)
            separatorStyle = configuration.property(name: "separatorStyle", defaultValue: .singleLine)
            separatorColor = configuration.property(name: "separatorColor", defaultValue: .color(.named("gray")))
            separatorEffect = configuration.property(name: "separatorEffect")
            separatorInset = configuration.property(name: "separatorInset", defaultValue: EdgeInsets(left: 15))
            separatorInsetReference = configuration.property(name: "separatorInsetReference", defaultValue: .fromCellEdges)
            cellLayoutMarginsFollowReadableWidth = configuration.property(name: "cellLayoutMarginsFollowReadableWidth")
            sectionHeaderHeight = configuration.property(name: "sectionHeaderHeight", defaultValue: -1)
            sectionFooterHeight = configuration.property(name: "sectionFooterHeight", defaultValue: -1)
            estimatedRowHeight = configuration.property(name: "estimatedRowHeight", defaultValue: -1)
            estimatedSectionHeaderHeight = configuration.property(name: "estimatedSectionHeaderHeight", defaultValue: -1)
            estimatedSectionFooterHeight = configuration.property(name: "estimatedSectionFooterHeight", defaultValue: -1)
            allowsSelection = configuration.property(name: "allowsSelection", defaultValue: true)
            allowsMultipleSelection = configuration.property(name: "allowsMultipleSelection")
            allowsSelectionDuringEditing = configuration.property(name: "allowsSelectionDuringEditing")
            allowsMultipleSelectionDuringEditing = configuration.property(name: "allowsMultipleSelectionDuringEditing")
            dragInteractionEnabled = configuration.property(name: "dragInteractionEnabled", defaultValue: true)
            isEditing = configuration.property(name: "isEditing")
            sectionIndexMinimumDisplayRowCount = configuration.property(name: "sectionIndexMinimumDisplayRowCount")
            sectionIndexColor = configuration.property(name: "sectionIndexColor")
            sectionIndexBackgroundColor = configuration.property(name: "sectionIndexBackgroundColor")
            sectionIndexTrackingBackgroundColor = configuration.property(name: "sectionIndexTrackingBackgroundColor")
            remembersLastFocusedIndexPath = configuration.property(name: "remembersLastFocusedIndexPath")
            insetsContentViewsToSafeArea = configuration.property(name: "insetsContentViewsToSafeArea", defaultValue: true)

            super.init(configuration: configuration)
        }
    }
}

extension Module.UIKit.RowHeight {
    public final class TypeFactory: TypedAttributeSupportedTypeFactory, HasZeroArgumentInitializer {
        public typealias BuildType = Module.UIKit.RowHeight

        public var xsdType: XSDType {
            let valueType = Float.typeFactory.xsdType
            let automaticType = XSDType.enumeration(EnumerationXSDType(name: "rowHeightAuto", base: .string, values: [automaticIdentifier]))

            return XSDType.union(UnionXSDType(name: "rowHeight", memberTypes: [valueType, automaticType]))
        }

        public init() { }

        public func typedMaterialize(from value: String) throws -> Module.UIKit.RowHeight {
            if value == automaticIdentifier {
                return .automatic
            } else {
                return try .value(Float.typeFactory.typedMaterialize(from: value))
            }
        }

        public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
            return RuntimeType(name: "CGFloat", module: "CoreGraphics")
        }
    }
}
