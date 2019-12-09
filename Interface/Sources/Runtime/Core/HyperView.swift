//
//  HyperView.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

public protocol ComposableHyperView: AnyObject {
    associatedtype StateType: HyperViewState
    associatedtype ActionType

    var actionPublisher: ActionPublisher<ActionType> { get }

    var state: StateType { get }

    static var triggerReloadPaths: Set<String> { get }
}

extension ComposableHyperView {
    public static var triggerReloadPaths: Set<String> {
        return []
    }
}

public protocol HyperView: ComposableHyperView {
    init(initialState: StateType, actionPublisher: ActionPublisher<ActionType>)
}

#if canImport(UIKit)
import UIKit

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
#else
import AppKit

open class HyperViewBase: NSView {
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
#endif

open class ConfigurableHyperViewBase: HyperViewBase, Configurable {
    open var configuration: Configuration = .global {
        didSet {
            #if os(iOS)
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            #endif
            #if canImport(UIKit)
            configuration.get(valueFor: Properties.Style.view)(self)
            #endif
        }
    }
}
