//
//  HyperViewManager.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

public class HyperViewManager<View: Platform.View & ComposableHyperView> {
    private var state: View.State
    private weak var view: View? {
        didSet {
            notifyViewChanged()
        }
    }

    private let factory: (ActionPublisher<View.Action>) -> View

    public init(initialState: View.State, factory: @escaping (ActionPublisher<View.Action>) -> View) {
        state = initialState
        self.factory = factory
    }

    public func load(actionHandler: @escaping (View.Action) -> Void) -> View {
        let view = factory(ActionPublisher(publisher: actionHandler))
        self.view = view
        return view
    }

    private func notifyViewChanged() {
        view?.state.apply(from: state)
    }
}
