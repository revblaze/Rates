//
//  AppDelegate.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  
  
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
    Settings.onAppClose()
    
  }
  
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  
}

