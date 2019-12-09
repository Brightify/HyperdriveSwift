//
//  SimpleCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class SimpleCollectionView<CELL: UIView>: FlowCollectionViewBase<CELL.StateType, SimpleCollectionView<CELL>.Action>, UICollectionViewDataSource where CELL: HyperView {
    public enum Action {
        case selected(CELL.StateType)
        case cellAction(CELL.StateType, CELL.ActionType)
        case refresh
    }

    public typealias MODEL = CELL.StateType
    
    private let cellIdentifier = CollectionViewCellIdentifier<CELL>()

    private let cellFactory: () -> CELL
    
    public init(cellFactory: @escaping () -> CELL = CELL.init,
                reloadable: Bool = true,
                automaticallyDeselect: Bool = true) {
        self.cellFactory = cellFactory
        
        super.init(reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)

        loadView()
    }
    
    private func loadView() {
        collectionView.register(identifier: cellIdentifier)

        collectionView.dataSource = self
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            for: indexPath,
            factory: cellFactory,
            model: model,
            mapAction: { SimpleCollectionView.Action.cellAction(model, $0) })
    }

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        actionPublisher.publish(action: .selected(items[indexPath.row]))
    }

    open override func performRefresh() {
        super.performRefresh()

        actionPublisher.publish(action: .refresh)
    }
}
#endif
