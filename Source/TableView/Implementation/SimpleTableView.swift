//
//  SimpleTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum SimpleTableViewAction<HEADER: HyperView, CELL: HyperView, FOOTER: HyperView> {
    case selected(CELL.State)
    case headerAction(HEADER.State, HEADER.Action)
    case rowAction(CELL.State, CELL.Action)
    case footerAction(FOOTER.State, FOOTER.Action)
    case refresh
}

open class SimpleTableView<HEADER: UIView, CELL: UIView, FOOTER: UIView>: TableViewBase<SectionModel<(header: HEADER.State, footer: FOOTER.State), CELL.State>, SimpleTableViewAction<HEADER, CELL, FOOTER>>, UITableViewDataSource where HEADER: HyperView, CELL: HyperView, FOOTER: HyperView {

    public typealias MODEL = CELL.State
    public typealias SECTION = SectionModel<(header: HEADER.State, footer: FOOTER.State), CELL.State>
    
    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let headerIdentifier = TableViewHeaderFooterIdentifier<HEADER>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<FOOTER>()

    private let cellFactory: () -> CELL
    private let headerFactory: () -> HEADER
    private let footerFactory: () -> FOOTER

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions = .default)
    {
        self.cellFactory = cellFactory
        self.headerFactory = headerFactory
        self.footerFactory = footerFactory

        super.init(style: style, options: options)
    }
    
    open override func loadView() {
        super.loadView()
        
        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: headerIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].items.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.section].items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            factory: cellFactory,
            model: model,
            mapAction: { SimpleTableViewAction.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.section].items[indexPath.row]
        perform(action: .selected(model))
    }

    open override func performRefresh() {
        super.performRefresh()

        perform(action: .refresh)
    }

    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = items[section].model.header
        return dequeueAndConfigure(identifier: headerIdentifier, factory: headerFactory,
                                   model: model, mapAction: { SimpleTableViewAction.headerAction(model, $0) })
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let model = items[section].model.footer
        return dequeueAndConfigure(identifier: footerIdentifier, factory: footerFactory,
                                   model: model, mapAction: { SimpleTableViewAction.footerAction(model, $0) })
    }
}
#endif
