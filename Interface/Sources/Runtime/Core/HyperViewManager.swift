//
//  HyperViewManager.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

public class HyperViewManager<View: Platform.View & ComposableHyperView> {
    private var state: View.StateType
    private weak var view: View? {
        didSet {
            notifyViewChanged()
        }
    }

    private let factory: (ActionPublisher<View.ActionType>) -> View

    public init(initialState: View.StateType, factory: @escaping (ActionPublisher<View.ActionType>) -> View) {
        state = initialState
        self.factory = factory
    }

    public func load(actionHandler: @escaping (View.ActionType) -> Void) -> View {
        let view = factory(ActionPublisher(publisher: actionHandler))
        self.view = view
        return view
    }

    private func notifyViewChanged() {
        view?.state.apply(from: state)
    }
}
