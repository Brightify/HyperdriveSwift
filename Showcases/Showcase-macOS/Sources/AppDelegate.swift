//
//  AppDelegate.swift
//  Showcase-macOS
//
//  Created by Matyáš Kříž on 02/07/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentController = ViewController()
        window.contentViewController = contentController
        window.center()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
