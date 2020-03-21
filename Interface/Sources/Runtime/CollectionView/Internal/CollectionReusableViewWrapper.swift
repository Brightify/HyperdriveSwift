//
//  CollectionReusableViewWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class CollectionReusableViewWrapper<VIEW: UIView>: UICollectionReusableView, Configurable {
    private let contentViewEdgePriority = UILayoutPriority(900)

    public var configurationChangeTime: clock_t = 0
    
    private var wrappedView: VIEW?
        
    public var configuration: Configuration = .global {
        didSet {
            (wrappedView as? Configurable)?.configuration = configuration
            configuration.get(valueFor: Properties.Style.CollectionView.reusableViewWrapper)(self)
        }
    }

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private var wrappedViewConstraints: [NSLayoutConstraint] = []

    public override func updateConstraints() {
        super.updateConstraints()

        if wrappedViewConstraints.contains(where: { $0.firstItem !== wrappedView && $0.secondItem !== wrappedView }) || wrappedView == nil {
            NSLayoutConstraint.deactivate(wrappedViewConstraints)
            wrappedViewConstraints = []
        }
        if let wrappedView = wrappedView, wrappedViewConstraints.isEmpty {
            let newWrappedViewConstraints = [
                wrappedView.leftAnchor.constraint(equalTo: leftAnchor),
                wrappedView.topAnchor.constraint(equalTo: topAnchor),
                wrappedView.rightAnchor.constraint(equalTo: rightAnchor),
                wrappedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
            for constraint in newWrappedViewConstraints {
                constraint.priority = contentViewEdgePriority
            }
            NSLayoutConstraint.activate(newWrappedViewConstraints)
            wrappedViewConstraints.append(contentsOf: newWrappedViewConstraints)
        }
    }
    
    public func cachedViewOrCreated(factory: () -> VIEW) -> VIEW {
        if let wrappedView = wrappedView {
            return wrappedView
        } else {
            let wrappedView = factory()
            wrappedView.translatesAutoresizingMaskIntoConstraints = false
            (wrappedView as? Configurable)?.configuration = configuration
            self.wrappedView = wrappedView
            addSubview(wrappedView)
            setNeedsUpdateConstraints()
            return wrappedView
        }
    }
    
    public func deleteCachedView() -> VIEW? {
        let wrappedView = self.wrappedView
        wrappedView?.removeFromSuperview()
        self.wrappedView = nil
        return wrappedView
    }
}
#endif
