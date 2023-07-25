//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

/// Extension of the `ViewController` class to add additional methods related to file importing.
extension ViewController {
  
  /// Passes data from a file with a given URL
  ///
  /// - Parameters:
  ///   - fileUrl: The URL of the file.
  func passDataToTableView(fileUrl: URL) {
    Debug.log("[passDataToTableView] url: \(fileUrl)")
    
    // Perform UI updates on main queue
    DispatchQueue.main.async {
      self.updateStatusBar(withState: .loadingUserData)
      // If there is no tableData, don't gray out screen
      if self.csvTableView.tableData.isEmpty == false {
        self.disableMainViewInteraction()
      }
    }
    
    // Perform file conversion in a background queue
    DispatchQueue.global(qos: .userInitiated).async {
      guard
        let csvFileUrl = ConvertFile.toCSV(fileUrl: fileUrl)
      else {
        // Add error handling here
        Debug.log("[passDataToTableView] Error converting file to CSV or restructuring CSV for table view.")
        // Failed to pass file data to CSVTableView
        DispatchQueue.main.async {
          self.updateStatusBar(withState: .failedToLoadUserData)  // Update status bar to be failedToLoadUserData
          self.enableMainViewInteraction()                        // Re-enable main view interaction
          
          // If user has previously loaded a file this session and table is not populated with launch screen data:
          if self.userHasPreviouslyLoadedInputFileThisSession && !self.tableIsPopulatedWithLaunchScreenData {
            self.enableToolbarItemsOnFileLoad()   // Re-enable toolbar items for file editing
          } else {
            // Else, only enable openFile button.
            self.enableToolbarItemsForPostLaunchState()
          }
        }
        return
      }
      
      Debug.log("csvFileUrl = ConvertFile.toCSV : \(csvFileUrl)")
      
      // Once file conversion is done, update UI on main queue
      DispatchQueue.main.async {
        self.updateCSVTableViewWithCSV(at: csvFileUrl)      // Update the CSVTableView with user data
        self.tableIsPopulatedWithLaunchScreenData = false   // Set launch screen data flag to flase
        self.updateStatusBar(withState: .upToDate)          // Update status bar to be upToDate
        self.enableMainViewInteraction()                    // Enable main view interaction
        self.enableToolbarItemsOnFileLoad()                 // Enable all toolbar items for editing
      }
    }
  }
  
  /// Updates the CSV table view with data from a CSV file with a given URL.
  ///
  /// - Parameters:
  ///   - url: The URL of the CSV file.
  func updateCSVTableViewWithCSV(at url: URL) {
    Debug.log("[updateCSVTableViewWithCSV] CSV: \(url)")
    
    if let detectionType = sharedData.inputUserFileExtension?.headerDetectionMethod {
      csvTableView.updateCSVData(with: url, withHeaderRowDetection: detectionType)
    } else {
      csvTableView.updateCSVData(with: url)
    }
    
    // Enable Toolbar items
    enableToolbarItemsOnFileLoad()
    // Set user session flag
    userHasPreviouslyLoadedInputFileThisSession = true
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
  
  func passFileUrlToTableAndUpdateSharedData(_ url: URL) {
    // Update SharedData
    sharedData.inputUserFile = url
    if let fileExtension = url.hasFileExtension() {
      sharedData.inputUserFileExtension = fileExtension
      sharedData.outputUserFileExtension = fileExtension
      //sharedData.outputUserFileFormat = fileExtension
    }
    
    DispatchQueue.main.async {
      // Hide FileDropBox if visible
      self.hideFileDropBox()
    }
    // Pass input file data to table view
    passDataToTableView(fileUrl: url)
  }
  
  /// Opens the file selection interface.
  func openFileSelection() {
    openUserFile { fileUrl in
      if let url = fileUrl {
        self.passFileUrlToTableAndUpdateSharedData(url)
      }
    }
  }
  
}
