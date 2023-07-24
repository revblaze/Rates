//
//  AppDelegate.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  /// The main window of the application.
  var mainWindow: NSWindow!
  
  /// Called when the application has finished launching.
  ///
  /// This function initializes the `mainWindow` and activates the application.
  /// It also initializes the Debug menu.
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    /// Set mainWindow as initial window presented
    mainWindow = NSApplication.shared.windows[0]
    NSApp.activate(ignoringOtherApps: true)
    /// Initialize Debug menu
    initDebugMenu()
    
    enableAllLaunchMenuItems()
  }
  
  /// Called when the application is about to terminate.
  ///
  /// This function is used to do some cleanup before the application is terminated.
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
    Settings.onAppClose()
    // Clear
    let clearStatus = Utility.clearApplicationSupportDirectory()
    Debug.log("Attempt at clear application support directory was successful: \(clearStatus)")
    
  }
  
  /// Called when the application is asked to handle a reactivation.
  ///
  /// If the application has no visible windows, it presents the `mainWindow`.
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    /// If the app has no visible windows, present `mainWindow`
    if !flag {
      mainWindow.makeKeyAndOrderFront(self)
    }
    return true
  }
  
  /// Indicates that the application supports secure restorable state.
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  func performActionOnViewController(action: @escaping (ViewController) -> Void) {
    guard let viewController = mainWindow.contentViewController as? ViewController else {
      return
    }
    
    DispatchQueue.main.async {
      action(viewController)
    }
  }
  
  /// Enables a specific main menu item.
  ///
  /// - Parameters:
  ///   - menuItem: The menu item to enable.
  ///   - action: The action to be performed when the menu item is pressed.
  func enableMenuItem(_ menuItem: NSMenuItem, action: Selector) {
    menuItem.action = action
    menuItem.target = self
  }
  
  
  /// An outlet for the Debug menu in the application.
  @IBOutlet weak var debugMenu: NSMenuItem!
  // MARK: App Menu
  @IBOutlet weak var settingsMenuItem: NSMenuItem!
  // MARK: File Menu
  @IBOutlet weak var openFileMenuItem: NSMenuItem!
  @IBOutlet weak var saveFileMenuItem: NSMenuItem!
  @IBOutlet weak var printFileMenuItem: NSMenuItem!
  // MARK: Table Menu
  @IBOutlet weak var toggleFiltersSidebarMenuItem: NSMenuItem!
  @IBOutlet weak var toggleHiddenColumnsMenuItem: NSMenuItem!
  @IBOutlet weak var toggleRoundToTwoDecimalPlacesMenuItem: NSMenuItem!
  @IBOutlet weak var convertToCurrencyMenuItem: NSMenuItem!
  // MARK: Help Menu
  @IBOutlet weak var quickStartGuideMenuItem: NSMenuItem!
  
}

