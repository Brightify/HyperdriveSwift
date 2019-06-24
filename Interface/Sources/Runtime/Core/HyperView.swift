//
//  HyperView.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import UIKit

public protocol ComposableHyperView: AnyObject {
    associatedtype State: HyperViewState
    associatedtype Action

    var actionPublisher: ActionPublisher<Action> { get }

    var state: State { get }

    static var triggerReloadPaths: Set<String> { get }
}

extension ComposableHyperView {
    public static var triggerReloadPaths: Set<String> {
        return []
    }
}

public protocol HyperView: ComposableHyperView {
    init(initialState: State, actionPublisher: ActionPublisher<Action>)
}

open class HyperViewBase: UIView {
    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported!")
    }
}

open class ConfigurableHyperViewBase: HyperViewBase, Configurable {
    open var configuration: Configuration = .global {
        didSet {
            #if os(iOS)
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            #endif
            configuration.get(valueFor: Properties.Style.view)(self)
        }
    }
}
