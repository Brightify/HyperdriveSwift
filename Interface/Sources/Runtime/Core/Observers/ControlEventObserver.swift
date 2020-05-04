//
//  ControlEventObserver.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 01/06/2019.
//

#if canImport(UIKit)
import UIKit

public final class ControlEventObserver<T: UIControl>: NSObject {
    private var associationKey: UInt8 = 0

    private weak var control: T?
    private let events: UIControl.Event
    private let callback: (T) -> Void

    private let selector = #selector(ControlEventObserver.eventHandler(_:))

    public init(control: T, events: UIControl.Event, callback: @escaping (T) -> Void) {
        self.control = control
        self.events = events
        self.callback = callback

        super.init()

        control.addTarget(self, action: selector, for: events)
    }

    @objc
    internal func eventHandler(_ sender: UIControl!) {
        guard let control = control else { return }
        callback(control)
    }

    deinit {
        control?.removeTarget(self, action: selector, for: events)
    }

    private func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public static func bind(to control: T, events: UIControl.Event, handler: @escaping () -> Void) {
        let observer = ControlEventObserver(control: control, events: events) { _ in
            handler()
        }
        observer.retained(in: control)
    }

    public static func bind<T: UITextField>(to control: T, events: UIControl.Event, handler: @escaping (String?) -> Void) {
        let observer = ControlEventObserver<T>(control: control, events: events) { control in
            handler(control.text)
        }
        observer.retained(in: control)
    }

    public static func bind<T: UISlider>(to control: T, events: UIControl.Event, handler: @escaping (Float) -> Void) {
        let observer = ControlEventObserver<T>(control: control, events: events) { control in
            handler(control.value)
        }
        observer.retained(in: control)
    }

    public static func bind<T: HyperTextField>(to control: T, events: UIControl.Event, handler: @escaping (String?) -> Void) {
        return bind(to: control.textField, events: events, handler: handler)
    }
}
#elseif canImport(AppKit)
import AppKit

public final class ControlEventObserver: NSObject {
    private var associationKey: UInt8 = 0

    private weak var control: NSControl?
    private let callback: (NSControl) -> Void

    private let selector = #selector(ControlEventObserver.eventHandler(_:))

    public init(control: NSControl, callback: @escaping (NSControl) -> Void) {
        self.control = control
        self.callback = callback

        super.init()

        control.target = self
        control.action = self.selector
    }

    @objc
    internal func eventHandler(_ sender: NSControl!) {
        guard let control = control else { return }
        callback(control)
    }

    deinit {
        control?.target = nil
        control?.action = nil
    }

    private func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public static func bind(to control: NSControl, handler: @escaping () -> Void) {
        let observer = ControlEventObserver(control: control) { _ in
            handler()
        }
        observer.retained(in: control)
    }
}
#endif
