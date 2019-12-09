//
//  HyperViewController.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

open class ComposableHyperViewController<View: Platform.View & ComposableHyperView>: Platform.ViewController {
    public let viewManager: HyperViewManager<View>

    public var hyperView: View {
        guard let hyperView = view as? View else {
            fatalError("View was changed and it not an instance of \(View.self) anymore! If you do that, make sure to override this property to return the correct HyperView instance!")
        }
        return hyperView
    }

    public init(initialState: View.StateType, viewFactory: @escaping (ActionPublisher<View.ActionType>) -> View) {
        viewManager = HyperViewManager(initialState: initialState, factory: viewFactory)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) is not supported")
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    open override func loadView() {
        view = viewManager.load(actionHandler: handle(action:))

        if let hasNavigationItem = view as? HasNavigationItem {
            if navigationItem.leftBarButtonItems == nil && hasNavigationItem.leftBarButtonItems != nil {
                navigationItem.leftBarButtonItems = hasNavigationItem.leftBarButtonItems
            }
            if navigationItem.rightBarButtonItems == nil && hasNavigationItem.rightBarButtonItems != nil {
                navigationItem.rightBarButtonItems = hasNavigationItem.rightBarButtonItems
            }
        }
    }

    open func handle(action: View.ActionType) {
    }
}

open class HyperViewController<View: Platform.View & HyperView>: ComposableHyperViewController<View> {
    public init(initialState: View.StateType = View.StateType()) {
        super.init(initialState: initialState, viewFactory: { View(initialState: initialState, actionPublisher: $0) })
    }
}
