//
//  UIOffset+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit) && EnableHelperExtensions
import UIKit

public extension UIOffset {
    
    init(_ all: CGFloat) {
        self.init(horizontal: all, vertical: all)
    }
    
    init(horizontal: CGFloat) {
        self.init(horizontal: horizontal, vertical: 0)
    }
    
    init(vertical: CGFloat) {
        self.init(horizontal: 0, vertical: vertical)
    }
}
#endif
