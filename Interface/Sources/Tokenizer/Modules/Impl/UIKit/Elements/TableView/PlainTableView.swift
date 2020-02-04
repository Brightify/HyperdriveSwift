//
//  PlainTableView.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 4/22/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
import HyperdriveInterface
//import RxDataSources
#endif

enum TableViewSource {
    case fielded
    case anonymous(Cell)
}

enum Cell {
    case name(String)
    case cell(ComponentDefinition)
}

extension Module.UIKit {
    public class PlainTableView: View, ComponentDefinitionContainer {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.plainTableView.allProperties
        }

        public override class var availableToolingProperties: [PropertyDescription] {
            return ToolingProperties.plainTableView.allProperties
        }

        public var cellType: String
        public var cellDefinition: ComponentDefinition?
        public var options: TableView.TableViewOptions

        public var componentTypes: [String] {
            return cellDefinition?.componentTypes ?? [cellType].compactMap { $0 }
        }

        public var isAnonymous: Bool {
            return cellDefinition?.isAnonymous ?? false
        }

        public var componentDefinitions: [ComponentDefinition] {
            return cellDefinition?.componentDefinitions ?? []
        }

        public override class var parentModuleImport: String {
            return "Hyperdrive"
        }

        public required init(context: UIElementDeserializationContext, factory: UIElementFactory) throws {
            let node = context.element

            guard let cellType = node.value(ofAttribute: "cell") as String? else {
                throw TokenizationError(message: "cell for PlainTableView was not defined.")
            }

            self.cellType = cellType
            self.options = try TableView.TableViewOptions(node: node)

            if let cellElement = try node.singleOrNoElement(named: "cell") {
                cellDefinition = try context.deserialize(element: cellElement, type: cellType)
            } else {
                cellDefinition = nil
            }

            try super.init(context: context, factory: factory)
        }

        public class override func runtimeType() -> String {
            return "UITableView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            return RuntimeType(name: "PlainTableView<\(cellType)>", module: "Hyperdrive")
        }

        #if canImport(SwiftCodeGen)
        public override func initialization(for platform: RuntimePlatform, context: ComponentContext) throws -> Expression {
            return .invoke(target: .constant(try runtimeType(for: platform).name), arguments: [
                MethodArgument(name: "style", value: options.initialization(kind: .style)),
                MethodArgument(name: "options", value: options.initialization(kind: .tableViewOptions)),
                MethodArgument(name: "cellFactory", value: .invoke(target: .constant(cellType), arguments: [])),
            ])
        }
        #endif

        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var element = super.serialize(context: context)
            element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
            return element
        }

        public override func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
            return [
                PlainTableViewAction.rowAction(cellType: cellType),
                PlainTableViewAction.selected(cellType: cellType),
                PlainTableViewAction.refresh,
            ]
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            #warning("TODO Use `options` for instantiation.")
            let createCell = try context.componentInstantiation(named: cellType)
            let exampleCount = ToolingProperties.plainTableView.exampleCount.get(from: self.toolingProperties)?.value ?? 5
            let tableView = HyperdriveInterface.PlainTableView<CellWrapper>(options: [], cellFactory: CellWrapper(wrapped: createCell()))
            tableView.state.items = .items(Array(repeating: EmptyState(), count: exampleCount))

            tableView.tableView.rowHeight = UITableView.automaticDimension

            return tableView
        }
        #endif
    }

    public class PlainTableViewProperites: PropertyContainer {
        public let tableViewProperties: TableViewProperties
        public let emptyLabelProperties: LabelProperties
        public let loadingIndicatorProperties: ActivityIndicatorProperties

        public required init(configuration: Configuration) {
            tableViewProperties = configuration.namespaced(in: "tableView", TableViewProperties.self)
            emptyLabelProperties = configuration.namespaced(in: "emptyLabel", LabelProperties.self)
            loadingIndicatorProperties = configuration.namespaced(in: "loadingIndicator", ActivityIndicatorProperties.self)

            super.init(configuration: configuration)
        }
    }

    public class PlainTableViewToolingProperties: PropertyContainer {
        public let exampleCount: StaticValuePropertyDescription<Int>

        public required init(configuration: Configuration) {
            exampleCount = configuration.property(name: "tools:exampleCount")

            super.init(configuration: configuration)
        }
    }
}
