//
//  StackViewRootView.swift
//  Example
//
//  Created by Matouš Hýbl on 02/04/2018.
//

import UIKit

extension StackViewRootView {
    func afterInit() {
        let view = UIView()
        view.snp.makeConstraints { make in make.height.equalTo(20) }
        view.backgroundColor = .red
        stackView.addArrangedSubview(view)
    }
}
