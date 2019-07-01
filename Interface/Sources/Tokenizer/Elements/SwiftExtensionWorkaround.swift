//
//  SwiftExtensionWorkaround.swift
//  hyperdrive
//
//  Created by Matyáš Kříž on 26/06/2019.
//

import Foundation

#if canImport(SwiftCodeGen) && canImport(UIKit)
public protocol SwiftExtensionWorkaround: ProvidesCodeInitialization, CanInitializeUIKitView { }
#elseif canImport(SwiftCodeGen) && HyperdriveRuntime && canImport(AppKit)
public protocol SwiftExtensionWorkaround: ProvidesCodeInitialization, CanInitializeAppKitView { }
#elseif canImport(SwiftCodeGen)
public protocol SwiftExtensionWorkaround: ProvidesCodeInitialization { }
#elseif canImport(UIKit) && HyperdriveRuntime
public protocol SwiftExtensionWorkaround: CanInitializeUIKitView { }
#elseif canImport(AppKit) && HyperdriveRuntime
public protocol SwiftExtensionWorkaround: CanInitializeAppKitView { }
#else
public protocol SwiftExtensionWorkaround { }
#endif
