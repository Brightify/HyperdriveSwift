//
//  UIViewController+Navigation.swift
//  Platform
//
//  Created by Tadeas Kriz on 12/01/2020.
//

#if canImport(UIKit)
import UIKit

extension Platform.ViewController {

    /**
     * Presents a view controller.
     * - parameter controller: generic controller to present
     * - parameter animated: determines whether the view controller presentation should be animated, default is `true`
     * - parameter completion: closure to run after the controller is presented, default is `nil`
     */
    public func present(controller: Platform.ViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(controller, animated: animated, completion: completion)
    }

    /**
     * Dismisses topmost view controller.
     * - parameter animated: determines whether the view controller dismissal should be animated, default is `true`
     */
    public func dismiss(animated: Bool = true) {
        dismiss(animated: animated, completion: nil)
    }

    /**
     * Dismisses topmost view controller.
     * - parameter completion: closure to run after the controller is dismissed.
     */
    public func dismiss(completion: @escaping () -> Void) {
        dismiss(animated: true, completion: completion)
    }
}

#endif
