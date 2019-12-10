//
//  UIButton+Utils.swift
//  Reactant
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit) && EnableHelperExtensions
import UIKit

extension UIButton {
    
    public convenience init(title: String) {
        self.init()
        
        setTitle(title, for: UIControl.State())
    }
}

extension UIButton {

//    @objc(setBackgroundColor:forState:)
//    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
//        let rectangle = CGRect(size: CGSize(1));
//        UIGraphicsBeginImageContext(rectangle.size);
//
//        let context = UIGraphicsGetCurrentContext();
//        context?.setFillColor(color.cgColor);
//        context?.fill(rectangle);
//
//        let image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        setBackgroundImage(image!, for: state)
//    }
}
#endif
