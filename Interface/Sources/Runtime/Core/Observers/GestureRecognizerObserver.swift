//
//  GestureRecognizerObserver.swift
//  Interface
//
//  Created by Tadeas Kriz on 17/06/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

public final class GestureRecognizerObserver: NSObject {
    private var associationKey: UInt8 = 0

    private let handler: () -> Void

    public init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    @objc
    internal func action(sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        handler()
    }

    public func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public static func bindTap(to view: UIView, handler: @escaping () -> Void) {
        let observer = GestureRecognizerObserver(handler: handler)
        let recognizer = UITapGestureRecognizer(target: observer, action: #selector(action))
        observer.retained(in: recognizer)
        view.addGestureRecognizer(recognizer)
    }
}
#endif
