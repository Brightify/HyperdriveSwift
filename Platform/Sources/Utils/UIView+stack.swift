//
//  UIView+stack.swift
//  Reactant
//
//  Created by Matouš Hýbl on 02/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/*public*/ extension UIView {

    /**
     * Stacks views in superview horizontally or vertically with defined spacing
     * - parameter views: views to be layed out in the container
     * - parameter withSpacing: spacing to be put between views
     * - parameter axis: axis along which the views should be layed out
     * - parameter lowerPriorityOfLastConstraint: sets last constraint priority to high if true,
                                                  this prevents breaking of constraints in cases of hiding
                                                  the whole parent view using constraints
     */
    func stack(views: [UIView],
                      withSpacing spacing: CGFloat = 0,
                      inset: UIEdgeInsets = .zero,
                      axis: NSLayoutConstraint.Axis = .horizontal,
                      lastConstraintPriority: UILayoutPriority = .required) {
        var previousView: UIView?
        let lastView = views.last

        for view in views {
            view.removeFromSuperview()
            addSubview(view)

            let leadingConstraint: NSLayoutConstraint?
            let topConstraint: NSLayoutConstraint?
            let trailingConstraint: NSLayoutConstraint?
            let bottomConstraint: NSLayoutConstraint?

            switch axis {
            case .horizontal:
                if let previousView = previousView {
                    leadingConstraint = view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor, constant: spacing)
                } else {
                    leadingConstraint = view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset.left)
                }

                topConstraint = view.topAnchor.constraint(equalTo: self.topAnchor, constant: inset.top)
                bottomConstraint = view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: inset.bottom)

                if view === lastView {
                    trailingConstraint = view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: inset.right)
                    trailingConstraint?.priority = lastConstraintPriority
                } else {
                    trailingConstraint = nil
                }

            case .vertical:

                if let previousView = previousView {
                    topConstraint = view.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: spacing)
                } else {
                    topConstraint = view.topAnchor.constraint(equalTo: self.topAnchor, constant: inset.top)
                }

                leadingConstraint = view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset.left)
                trailingConstraint = view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: inset.right)

                if view === lastView {
                    bottomConstraint = view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: inset.bottom)
                    bottomConstraint?.priority = lastConstraintPriority
                } else {
                    bottomConstraint = nil
                }

            @unknown default:
                leadingConstraint = nil
                topConstraint = nil
                trailingConstraint = nil
                bottomConstraint = nil
            }

            NSLayoutConstraint.activate([
                leadingConstraint,
                topConstraint,
                bottomConstraint,
                trailingConstraint,
            ].compactMap { $0 })

            previousView = view
        }
    }
}
#endif
