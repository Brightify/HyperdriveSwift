//
//  PlainTableViewObserver.swift
//  tuistInterface
//
//  Created by Tadeas Kriz on 07/12/2019.
//

import Foundation

//
//  ControlEventObserver.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 01/06/2019.
//

#if canImport(UIKit)
import UIKit

public final class PlainTableViewObserver<CELL: HyperView & UIView>: NSObject {
    private var associationKey: UInt8 = 0

    private weak var tableView: PlainTableView<CELL>?
    private let callback: (PlainTableView<CELL>.Action) -> Void

    private let selector = #selector(ControlEventObserver.eventHandler(_:))

    public init(tableView: PlainTableView<CELL>, callback: @escaping (PlainTableView<CELL>.Action) -> Void) {
        self.tableView = tableView
        self.callback = callback

        super.init()

        tableView.actionPublisher.setListener(forObjectKey: self) { action in
            callback(action)
        }
    }

    deinit {
        tableView?.actionPublisher.removeListener(forObjectKey: self)
    }

    private func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public static func bindSelected(to tableView: PlainTableView<CELL>, handler: @escaping (CELL.State, IndexPath) -> Void) {

        let observer = PlainTableViewObserver(tableView: tableView, callback: { action in
            guard case .selected(let state, let indexPath) = action else { return }
            handler(state, indexPath)
        })

        observer.retained(in: tableView)
    }

    public static func bindRowAction(to tableView: PlainTableView<CELL>, handler: @escaping (CELL.State, CELL.Action) -> Void) {
        let observer = PlainTableViewObserver(tableView: tableView, callback: { action in
            guard case .rowAction(let state, let action) = action else { return }
            handler(state, action)
        })

        observer.retained(in: tableView)
    }

    public static func bindRefresh(to tableView: PlainTableView<CELL>, handler: @escaping () -> Void) {
        let observer = PlainTableViewObserver(tableView: tableView, callback: { action in
            guard case .refresh = action else { return }
            handler()
        })

        observer.retained(in: tableView)
    }
}
#endif
