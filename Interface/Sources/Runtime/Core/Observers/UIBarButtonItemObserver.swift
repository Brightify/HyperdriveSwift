//
//  UIBarButtonItemObserver.swift
//  Interface
//
//  Created by Tadeas Kriz on 09/12/2019.
//

#if canImport(UIKit)
import UIKit

public final class UIBarButtonItemObserver: NSObject {
    private var associationKey: UInt8 = 0

    private weak var barButtonItem: UIBarButtonItem?
    private let callback: (UIBarButtonItem) -> Void

    private let selector = #selector(UIBarButtonItemObserver.eventHandler(_:))

    public init(item: UIBarButtonItem, callback: @escaping (UIBarButtonItem) -> Void) {
        self.barButtonItem = item
        self.callback = callback

        super.init()

        item.target = self
        item.action = selector
    }

    @objc
    internal func eventHandler(_ sender: UIBarButtonItem!) {
        guard let barButtonItem = barButtonItem else { return }
        callback(barButtonItem)
    }

    deinit {
        barButtonItem?.target = nil
        barButtonItem?.action = nil
    }

    private func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public static func bind(to item: UIBarButtonItem, handler: @escaping () -> Void) {
        let observer = UIBarButtonItemObserver(item: item) { _ in
            handler()
        }
        observer.retained(in: item)
    }
}
#endif
