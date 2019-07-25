//
//  ViewController.swift
//  Showcase-macOS
//
//  Created by Matyáš Kříž on 02/07/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Cocoa
import HyperdriveInterface

class ViewController: HyperViewController<GoodGame> {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.snp.makeConstraints { make in
            make.width.equalTo(480)
            make.height.equalTo(360)
        }
    }

    override func handle(action: GoodGame.Action) {
        switch action {
        case .moved(let value):
            print("moved here, moved there: \(value)")
        case .WTF:
            print("la buttona pressura")
        case .textko(let text):
            print("typedo la textuda: \(text)")
        }
    }
}
