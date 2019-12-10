//
//  UIView+traits.swift
//  ReactantUI
//
//  Created by Tadeáš Kříž on 04/05/2018.
//

#if canImport(UIKit)
import UIKit

public extension UIView {
    var traits: UITraitHelper {
        return UITraitHelper(for: self)
    }
}
#endif
