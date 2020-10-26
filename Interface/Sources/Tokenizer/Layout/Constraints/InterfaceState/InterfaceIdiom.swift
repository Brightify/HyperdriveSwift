//
//  InterfaceIdiom.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

public enum InterfaceIdiom {
    case pad
    case phone
    case tv
    case carPlay
    case mac
    case unspecified

    var description: String {
        switch self {
        case .pad:
            return "pad"
        case .phone:
            return "phone"
        case .tv:
            return "tv"
        case .carPlay:
            return "carPlay"
        case .mac:
            return "mac"
        case .unspecified:
            return "unspecified"
        }
    }

    #if canImport(UIKit)
    var runtimeValue: UIUserInterfaceIdiom {
        switch self {
        case .pad:
            return .pad
        case .phone:
            return .phone
        case .tv:
            return .tv
        case .carPlay:
            return .carPlay
        case .mac:
            if #available(iOS 14.0, *) {
                return .mac
            } else {
                return .unspecified
            }
        case .unspecified:
            return .unspecified
        }
    }
    #endif
}
