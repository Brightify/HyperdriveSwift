//
//  DialogControllerBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class DialogHyperViewController<View: UIView & HyperView>: HyperViewController<View> {
    public var dialogView: DialogView {
        return view as! DialogView
    }

    public override var hyperView: View {
        return dialogView.content as! View
    }

    #warning("TODO Add configuration capabilities back")
//    open /*override*/ var configuration: Configuration = .global {
//        didSet {
//            dialogView.configuration = configuration
//            configuration.get(valueFor: Properties.Style.dialogControllerRoot)(rootViewContainer)
//        }
//    }

    public override init(initialState: View.StateType = View.StateType()) {
        super.init(initialState: initialState)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    open override func loadView() {
        super.loadView()
        view = DialogView(content: view)
        
        view.addSubview(dialogView)
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let dismissalListener = presentingViewController as? DialogDismissalListener
        dismissalListener?.dialogWillDismiss()
        super.dismiss(animated: flag) {
            dismissalListener?.dialogDidDismiss()
            completion?()
        }
    }
}
#endif
