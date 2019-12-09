//
//  FooterTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
//import RxDataSources

public enum FooterTableViewAction<CELL: HyperView, FOOTER: HyperView> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case footerAction(FOOTER.StateType, FOOTER.ActionType)
    case refresh
}

open class FooterTableView<CELL: UIView, FOOTER: UIView>: TableViewBase<SectionModel<FOOTER.StateType, CELL.StateType>, FooterTableViewAction<CELL, FOOTER>>, UITableViewDataSource where CELL: HyperView, FOOTER: HyperView {
    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<FOOTER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<FOOTER>()

    private let cellFactory: () -> CELL
    private let footerFactory: () -> FOOTER

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions = .default)
    {
        self.cellFactory = cellFactory
        self.footerFactory = footerFactory

        super.init(style: style, options: options)

        loadView()
    }

    private func loadView() {
        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
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
            mapAction: { FooterTableViewAction.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.section].items[indexPath.row]
        actionPublisher.publish(action: .selected(model))
    }

    open override func performRefresh() {
        super.performRefresh()

        actionPublisher.publish(action: .refresh)
    }

    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = items[section].model
        return dequeueAndConfigure(
            identifier: footerIdentifier,
            factory: footerFactory,
            model: section,
            mapAction: { FooterTableViewAction.footerAction(section, $0) })
    }
}
#endif
