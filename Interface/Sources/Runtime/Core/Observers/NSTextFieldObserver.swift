//
//  NSTextFieldObserver.swift
//  Interface-macOS
//
//  Created by Matyáš Kříž on 04/07/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

#if canImport(AppKit)
import AppKit

public final class NSTextFieldObserver: NSObject, NSTextFieldDelegate {
    private var associationKey: UInt8 = 1

    private let handler: (String) -> Void

    init(handler: @escaping (String) -> Void) {
        self.handler = handler
    }

    private func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }

    public func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return assertionFailure("ERROR: NSControl that NSTextFieldObserver was installed to is not an NSTextField.")
        }
        handler(textField.stringValue)
    }

    public static func bind(to textField: NSTextField, handler: @escaping (String) -> Void) {
        let observer = NSTextFieldObserver { text in
            handler(text)
        }
        textField.delegate = observer
        observer.retained(in: textField)
    }
}
#endif
