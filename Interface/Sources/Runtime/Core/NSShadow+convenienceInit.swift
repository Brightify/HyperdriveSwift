//
//  NSShadow+convenienceInit.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

#if canImport(UIKit)
import UIKit

extension NSShadow {
    public convenience init(offset: CGSize?, blurRadius: CGFloat, color: UIColor?) {
        self.init()
        if let offset = offset {
            self.shadowOffset = offset
        }
        self.shadowBlurRadius = blurRadius
        if let color = color {
            self.shadowColor = color
        }
    }
}
#else
import AppKit

extension NSShadow {
    public convenience init(offset: NSSize?, blurRadius: CGFloat, color: NSColor?) {
        self.init()
        if let offset = offset {
            self.shadowOffset = offset
        }
        self.shadowBlurRadius = blurRadius
        if let color = color {
            self.shadowColor = color
        }
    }
}
#endif
