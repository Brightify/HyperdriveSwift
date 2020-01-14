//
//  PreviewRootView.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import HyperdriveInterface
import UIKit

class ViewContainer: UIView {
    var containedView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            fillWithPreviewingView()
        }
    }

    private func fillWithPreviewingView() {
        guard let containedView = containedView else { return }

        [
            containedView
        ].forEach(addSubview(_:))

        containedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

final class PreviewRootView: HyperViewBase, HyperView {
    final class State: HyperViewState {
        fileprivate weak var owner: PreviewRootView? { didSet { resynchronize() } }
        var previewing: UIView? { didSet { } }

        init() { }

        func apply(from otherState: State) {
            previewing = otherState.previewing
        }

        func resynchronize() {
            notifyPreviewingChanged()
        }

        private func notifyPreviewingChanged() {
            owner?.container1.containedView = previewing
        }
    }
    enum Action {

    }

    static var triggerReloadPaths: Set<String> {
        return []
    }

    var state: State {
        willSet { state.owner = nil }
        didSet { state.owner = self }
    }
    let actionPublisher: ActionPublisher<Action>

    private let container1 = ViewContainer()

    required init(initialState: State, actionPublisher: ActionPublisher<Action>) {
        self.state = initialState
        self.actionPublisher = actionPublisher

        super.init()

        loadView()

        initialState.owner = self
    }

    private func loadView() {
        [
            container1
        ].forEach(addSubview)

        container1.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        }
    }
}
