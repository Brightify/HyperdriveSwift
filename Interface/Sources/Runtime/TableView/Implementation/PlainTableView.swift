//
//  PlainTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class PlainTableView<CELL: UIView>: TableViewBase<CELL.State, PlainTableView<CELL>.Action>, UITableViewDataSource where CELL: HyperView {
    public enum Action {
        case selected(CELL.State, indexPath: IndexPath)
        case rowAction(CELL.State, CELL.Action)
        case refresh
    }

    public typealias MODEL = CELL.State

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    private let cellFactory: () -> CELL

    public init(
        style: UITableView.Style = .plain,
        options: TableViewOptions = .default,
        cellFactory: @autoclosure @escaping () -> CELL)
    {
        self.cellFactory = cellFactory

        super.init(style: style, options: options)

        loadView()
    }

    private func loadView() {
        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            factory: cellFactory,
            model: model,
            mapAction: { Action.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.row]
        actionPublisher.publish(action: .selected(model, indexPath: indexPath))
    }

    open override func performRefresh() {
        super.performRefresh()

        actionPublisher.publish(action: .refresh)
    }
}
#endif
