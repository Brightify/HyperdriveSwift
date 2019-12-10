//
//  BlockBarButtonItem.swift
//  Hyperdrive-iOS
//
//  Created by Tadeas Kriz on 10/12/2019.
//

import UIKit

internal final class BlockBarButtonItem: UIBarButtonItem {
    private let actionHandler: (() -> Void)?

    required init?(coder: NSCoder) {
        actionHandler = nil

        super.init(coder: coder)
    }

    override init() {
        actionHandler = nil

        super.init()
    }

    init(title: String?, style: UIBarButtonItem.Style, action: @escaping () -> Void) {
        self.actionHandler = action

        super.init()

        self.title = title
        self.style = style
        self.target = self
        self.action = #selector(performAction)
    }

    @objc
    private func performAction() {
        actionHandler?()
    }
}
