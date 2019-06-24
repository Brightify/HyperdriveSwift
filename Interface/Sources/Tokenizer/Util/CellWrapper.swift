//
//  CellWrapper.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
import HyperdriveInterface
import RxDataSources
    
public final class CellWrapper: HyperViewBase, HyperView {
    public typealias State = EmptyState
    public typealias Action = Void

    private let wrapped: UIView

    public let actionPublisher: ActionPublisher<Action>
    public let state: State

    public init(initialState: State = State(), actionPublisher: ActionPublisher<Action>) {
        state = initialState
        self.actionPublisher = actionPublisher
        wrapped = UIView()

        super.init()

        loadView()
        setupConstraints()
    }

    public init(wrapped: UIView) {
        self.wrapped = wrapped
        self.state = State()
        self.actionPublisher = ActionPublisher()

        super.init()

        loadView()
        setupConstraints()
    }

    private func loadView() {
        [
            wrapped
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        wrapped.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
#endif
