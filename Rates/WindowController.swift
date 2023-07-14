//
//  WindowController.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

/// The main window controller for the application.
class WindowController: NSWindowController, FileSelectionDelegate {
  
  @IBOutlet weak var selectCustomHeaderRowButton: NSToolbarItem!
  
  /// The main view controller of the window.
  lazy var viewController: ViewController = {
    let vc = self.window?.contentViewController as! ViewController
    vc.delegate = self
    return vc
  }()
  
  /// Performs an action on the view controller to open a file selection.
  @IBAction func openFileAction(_ sender: Any) {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  /// Performs an action on the view controller to revert changes to the table view.
  @IBAction func revertTableViewChanges(_ sender: Any) {
    performActionOnViewController(action: viewController.revertTableViewChanges)
  }
  
  /// Performs an action on the view controller to filter App Store Connect sales.
  @IBAction func filterAppStoreConnectSales(_ sender: Any) {
    performActionOnViewController(action: viewController.filterAppStoreConnectSales)
  }
  
  /// Performs an action on the view controller to manually select the current table view row as the header row.
  @IBAction func selectCustomHeaderRowFromTable(_ sender: Any) {
    performActionOnViewController(action: viewController.selectCustomHeaderForTableView)
  }
  
  /// Calls the file selection in the view controller.
  func callOpenFileSelection() {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  /// Processes the selected file URL.
  ///
  /// - Parameters:
  ///   - viewController: The view controller where the file was selected.
  ///   - fileURL: The URL of the selected file.
  func fileSelected(_ viewController: ViewController, fileURL: URL) {
    Debug.log("Selected file: \(fileURL)")
    // Process the selected file URL
  }
  
  /// Performs an action on the view controller.
  ///
  /// - Parameter action: The action to perform.
  private func performActionOnViewController(action: () -> ()) {
    action()
  }
}
