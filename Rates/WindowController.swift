//
//  WindowController.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

// MARK: - WindowController
class WindowController: NSWindowController, FileSelectionDelegate {
  
  lazy var viewController: ViewController = {
    let vc = self.window?.contentViewController as! ViewController
    vc.delegate = self
    return vc
  }()
  
  @IBAction func openFileAction(_ sender: Any) {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  @IBAction func revertTableViewChanges(_ sender: Any) {
    performActionOnViewController(action: viewController.revertTableViewChanges)
  }
  
  @IBAction func filterAppStoreConnectSales(_ sender: Any) {
    performActionOnViewController(action: viewController.filterAppStoreConnectSales)
  }
  
  // Function to call the file selection in ViewController
  func callOpenFileSelection() {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  // Implement the FileSelectionDelegate method
  func fileSelected(_ viewController: ViewController, fileURL: URL) {
    Debug.log("Selected file: \(fileURL)")
    // Process the selected file URL
  }
  
  // Helper method to avoid code duplication
  private func performActionOnViewController(action: () -> ()) {
    action()
  }
}
