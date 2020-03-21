//
//  CollectionViewCellWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class CollectionViewCellWrapper<CELL: UIView>: UICollectionViewCell, Configurable {
    private let contentViewEdgePriority = UILayoutPriority(900)

    public var configurationChangeTime: clock_t = 0
    
    private var cell: CELL?
    
    public var configuration: Configuration = .global {
        didSet {
            (cell as? Configurable)?.configuration = configuration
            configuration.get(valueFor: Properties.Style.CollectionView.cellWrapper)(self)
        }
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var preferredFocusedView: UIView? {
        return cell
    }

    @available(iOS 9.0, tvOS 9.0, *)
    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return cell.map { [$0] } ?? []
    }
    
    private var collectionViewCell: CollectionViewCell? {
        return cell as? CollectionViewCell
    }
    
    public override var isSelected: Bool {
        didSet {
            collectionViewCell?.setSelected(isSelected)
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            collectionViewCell?.setHighlighted(isHighlighted)
        }
    }

    private var cellConstraints: [NSLayoutConstraint] = []

    public override func updateConstraints() {
        super.updateConstraints()

        if cellConstraints.contains(where: { $0.firstItem !== cell && $0.secondItem !== cell }) || cell == nil {
            NSLayoutConstraint.deactivate(cellConstraints)
            cellConstraints = []
        }
        if let cell = cell, cellConstraints.isEmpty {
            let newCellConstraints = [
                cell.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                cell.topAnchor.constraint(equalTo: contentView.topAnchor),
                cell.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                cell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ]
            for constraint in newCellConstraints {
                constraint.priority = contentViewEdgePriority
            }
            NSLayoutConstraint.activate(newCellConstraints)
            cellConstraints.append(contentsOf: newCellConstraints)
        }
    }

    
    public func cachedCellOrCreated(factory: () -> CELL) -> CELL {
        if let cell = cell {
            return cell
        } else {
            let cell = factory()
            cell.translatesAutoresizingMaskIntoConstraints = false
            (cell as? Configurable)?.configuration = configuration
            self.cell = cell
            contentView.addSubview(cell)
            setNeedsUpdateConstraints()
            return cell
        }
    }
    
    public func deleteCachedCell() -> CELL? {
        let cell = self.cell
        cell?.removeFromSuperview()
        self.cell = nil
        return cell
    }
}
#endif
