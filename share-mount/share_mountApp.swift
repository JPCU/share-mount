//
//  share_mountApp.swift
//  share-mount
//
//  Created by Kevin Meziere on 5/25/23.
//

import SwiftUI

@main
struct share_mountApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject,NSApplicationDelegate{
    
    var statusItem: NSStatusItem?
    var popOver = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let menuView = statusMenu()
                
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: menuView)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = statusItem?.button{
            MenuButton.image = NSImage(systemSymbolName:"shield", accessibilityDescription: nil)
            MenuButton.action = #selector(MenuButtonToggle)
        }
    }
    @objc func  MenuButtonToggle(sender: AnyObject){
        if popOver.isShown {
                popOver.performClose(sender)
            }
        else{
            if let menuButton = statusItem?.button{
                self.popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
                popOver.contentViewController?.view.window?.makeKey()
            }
        }

    }
}
