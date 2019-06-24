//
//  ButtonActionDelegate.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public class ButtonActionDelegate {
    private let onTapped: () -> Void

    public init(onTapped: @escaping () -> Void) {
        self.onTapped = onTapped
    }

    public func bind(to button: UIButton) {
        button.addTarget(self, action: #selector(tapped(sender:)), for: UIControl.Event.touchUpInside)
    }

    @objc
    private func tapped(sender: UIButton) {
        onTapped()
    }
}
#endif
