//
//  UITabBarController+Styles.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/02/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if canImport(UIKit) && EnableHelperExtensions
import UIKit

extension UITabBarController: Styleable { }

public extension UITabBarController {
    
    func apply(style: Style<UITabBar>) {
        style(tabBar)
    }
    
    func apply(styles: Style<UITabBar>...) {
        styles.forEach(apply(style:))
    }
    
    func apply(styles: [Style<UITabBar>]) {
        styles.forEach(apply(style:))
    }
    
    func styled(using styles: Style<UITabBar>...) -> Self {
        styles.forEach(apply(style:))
        return self
    }
    
    func styled(using styles: [Style<UITabBar>]) -> Self {
        apply(styles: styles)
        return self
    }
    
    func with(_ style: Style<UITabBar>) -> Self {
        apply(style: style)
        return self
    }
}
#endif
