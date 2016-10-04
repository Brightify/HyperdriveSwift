//
//  ScrollControllerBase.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SwiftKit
import Lipstick
import RxSwift

open class ScrollControllerBase<MODEL, ROOT: UIView>: ControllerBase<MODEL, ROOT> {
    open let scrollView = UIScrollView()

    open override init(title: String = "", root: ROOT = ROOT()) {
        super.init(title: title, root: root)
    }

    open override func loadView() {
        view = ControllerRootView().styled(using: ReactantConfiguration.global.controllerRootStyle)

        view.children(
            scrollView.children(
                rootView
            )
        )
    }

    open override func updateRootViewConstraints() {
        scrollView.snp.updateConstraints { make in
            make.edges.equalTo(view)
        }

        rootView.snp.updateConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(scrollView)
            make.trailing.equalTo(view)
            make.bottom.equalTo(scrollView)
        }
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    open override func viewDidLayoutSubviews() {
        scrollView.contentSize = rootView.bounds.size

        super.viewDidLayoutSubviews()
    }
}

extension ScrollControllerBase: Scrollable {
    open func scrollToTop(animated: Bool) {
        scrollView.scrollToTop(animated: animated)
    }
}
