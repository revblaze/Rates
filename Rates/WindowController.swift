//
//  WindowController.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

class WindowController: NSWindowController, FileSelectionDelegate {
  // Create an instance of ViewController
  lazy var viewController: ViewController = {
    return self.window?.contentViewController as! ViewController
  }()
  
  @IBAction func openFileAction(_ sender: Any) {
    callOpenFileSelection()
  }
  
  // Function to call the file selection in ViewController
  func callOpenFileSelection() {
    viewController.delegate = self
    viewController.openFileSelection()
  }
  
  // Implement the FileSelectionDelegate method
  func fileSelected(_ viewController: ViewController, fileURL: URL) {
    print("Selected file: \(fileURL)")
    // Process the selected file URL
  }
}
