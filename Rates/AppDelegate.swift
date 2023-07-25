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
  /// The main window controller of the application.
  var mainWindowController: WindowController? // Add reference to WindowController
  
  /// Called when the application has finished launching.
  ///
  /// This function initializes the `mainWindow` and activates the application.
  /// It also initializes the Debug menu.
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Check if the mainWindowController is already created
    if mainWindowController == nil {
      // If it's not, create it
      mainWindowController = WindowController()
    }
    // Set mainWindow as initial window presented
    mainWindow = mainWindowController?.window
    //mainWindow = NSApplication.shared.windows[0]
    NSApp.activate(ignoringOtherApps: true)
    /// Initialize Debug menu
    initDebugMenu()
    
    enableAllLaunchMenuItems()
    
    let arguments = ProcessInfo.processInfo.arguments
    if arguments.count > 1 {
      _ = application(NSApp, openFile: arguments[1])
    }
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
  
  /// Opens a file with the application and prints the file's URL.
  ///
  /// This function is called by macOS when a file is opened with the application.
  /// The `filename` parameter will contain the full path of the file, which is then converted to a `URL` for easier handling.
  /// The function returns `true` if the file was opened successfully, or `false` if there was an error.
  ///
  /// - Parameters:
  ///   - sender: The application that is requesting to open the file.
  ///   - filename: The full path of the file to open.
  ///
  /// - Returns: `true` if the file was opened successfully, or `false` if there was an error.
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    let fileURL = URL(fileURLWithPath: filename)

    userOpenedFileFromFinderWithUrl = fileURL
    Debug.log("[AppDelegate] Opened file URL: \(fileURL)")
    
    // If main view is ready for function calls, trigger function directly.
    // Otherwise, ViewController will handle file queue.
    if mainViewDidAppearAndIsReadyForInteraction {
      performActionOnViewController { viewController in
        _ = viewController.userDidOpenFileWithFinderAndWillPassToTableView()
      }
    }
    
    return true
  }
  /// The URL of the file if the user opened with Finder or dragged onto dock.
  var userOpenedFileFromFinderWithUrl: URL?
  /// A flag for indicating if the view is ready for direct interaction with AppDelegate, or if it needs to queue data until ready.
  var mainViewDidAppearAndIsReadyForInteraction = false
  
  func finderFileIsReadyToBeQueued() {
    performActionOnViewController { viewController in
      _ = viewController.userDidOpenFileWithFinderAndWillPassToTableView()
    }
  }
  
  
  // MARK: - MainMenu
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
  
  func enableAllLaunchMenuItems() {
    enableAppMenuItems()
    enableFileMenuItems()
  }
  
  func enableFileLoadMenuItems() {
//    enableAppMenuItems()
//    enableFileMenuItems()
    enableSaveFileMenuItem()
    enableTableMenuItems()
  }
  
}

