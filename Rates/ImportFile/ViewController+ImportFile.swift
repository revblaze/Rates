//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

/// Extension of the `ViewController` class to add additional methods related to file importing.
extension ViewController {
  
  /// Passes data from a file with a given URL and file template to the table view.
  ///
  /// - Parameters:
  ///   - fileUrl: The URL of the file.
  ///   - withTemplate: The file template.
  func passDataToTableView(fileUrl: URL) {
    Debug.log("[passDataToTableView] url: \(fileUrl)")
      
      // Perform UI updates on main queue
      DispatchQueue.main.async {
        self.updateStatusBar(withState: .loadingUserData)
        self.disableMainViewInteraction()
      }
      
      // Perform file conversion in a background queue
      DispatchQueue.global(qos: .userInitiated).async {
        guard
          let csvFileUrl = ConvertFile.toCSV(fileUrl: fileUrl)
        else {
          // Add error handling here
          Debug.log("[passDataToTableView] Error converting file to CSV or restructuring CSV for table view.")
          return
        }
        
        // Once file conversion is done, update UI on main queue
        DispatchQueue.main.async {
          self.updateCSVTableViewWithCSV(at: csvFileUrl)
          self.updateStatusBar(withState: .upToDate)
          self.enableMainViewInteraction()
        }
      }
  }
  
  /// Updates the CSV table view with data from a CSV file with a given URL and file template.
  ///
  /// - Parameters:
  ///   - url: The URL of the CSV file.
  ///   - withTemplate: The file template. The default value is `.generic`.
  func updateCSVTableViewWithCSV(at url: URL) {
    Debug.log("[updateCSVTableViewWithCSV] CSV: \(url)")
    // Excel requires largest number of entries for header
    if url.hasFileExtension() == .xlsx {
      csvTableView.updateCSVData(with: url, withHeaderRowDetection: .largestNumberOfEntries)
    } else {
      csvTableView.updateCSVData(with: url)
    }
    // Enable Toolbar items
    enableToolbarItemsOnFileLoad()
  }
  
  /// Opens a file selected by the user and calls the completion handler with the URL of the file.
  ///
  /// - Parameter completion: The completion handler to call when the user has selected a file. The completion handler takes a single argument: the URL of the file.
  func openUserFile(completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.allowedFileTypes = FileExtensions.all
    
    openPanel.begin { result in
      if result == NSApplication.ModalResponse.OK, let fileUrl = openPanel.url {
        completion(fileUrl)
      } else {
        completion(nil)
      }
    }
  }
  
  /// Opens the file selection interface.
  func openFileSelection() {
    openUserFile { fileUrl in
      if let url = fileUrl {
        self.sharedData.inputUserFile = url
        
        if let fileExtension = url.hasFileExtension() {
          self.sharedData.inputUserFileExtension = fileExtension
          self.sharedData.outputUserFileExtension = fileExtension
          //self.sharedData.outputUserFileFormat = fileExtension
        }
        
//        self.updateStatusBar(withState: .loadingUserData)
//        self.disableMainViewInteraction()
        
        self.passDataToTableView(fileUrl: url)
      }
    }
  }
  
}
