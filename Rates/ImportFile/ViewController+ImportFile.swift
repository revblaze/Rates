//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

/// Extension of the `ViewController` class to add additional methods related to file importing.
extension ViewController {
  
  /// Presents an import file template sheet with a given URL and file template detection.
  ///
  /// - Parameters:
  ///   - fileUrl: The URL of the file.
  ///   - withDetection: The file template detection.
  func presentImportFileTemplateSheet(_ fileUrl: URL, withDetection: FileTemplates) {
    let storyboard = NSStoryboard(name: Constants.mainStoryboard, bundle: nil)
    guard let importFileTemplateViewController = storyboard.instantiateController(withIdentifier: Constants.importFileTemplateViewControllerIdentifier) as? ImportFileTemplateViewController else {
      Debug.log("Unable to instantiate ImportFileTemplateViewController from storyboard")
      return
    }
    
    importFileTemplateViewController.fileUrl = fileUrl
    importFileTemplateViewController.withDetection = withDetection
    
    self.presentAsSheet(importFileTemplateViewController)
  }
  
  /// Passes data from a file with a given URL and file template to the table view.
  ///
  /// - Parameters:
  ///   - fileUrl: The URL of the file.
  ///   - withTemplate: The file template.
  func passDataToTableView(fileUrl: URL, withTemplate: FileTemplates) {
    Debug.log("[passDataToTableView] withTemplate: \(withTemplate.rawValue) ")
    
    guard
      let csvFileUrl = ConvertFile.toCSV(fileUrl: fileUrl),
      let restructuredCsvFileUrl = StructureFile.forTableView(csvFileUrl: csvFileUrl, withTemplate: withTemplate)
    else {
      // Add error handling here
      Debug.log("[passDataToTableView] Error converting file to CSV or restructuring CSV for table view.")
      return
    }
    
    updateCSVTableViewWithCSV(at: restructuredCsvFileUrl, withTemplate: withTemplate)
    updateStatusBar(withState: .upToDate)
  }
  
  /// Updates the CSV table view with data from a CSV file with a given URL and file template.
  ///
  /// - Parameters:
  ///   - url: The URL of the CSV file.
  ///   - withTemplate: The file template. The default value is `.generic`.
  func updateCSVTableViewWithCSV(at url: URL, withTemplate: FileTemplates = .generic) {
    Debug.log("[updateCSVTableViewWithCSV] withTemplate: \(withTemplate.rawValue)")
    // Excel requires largest number of entries for header
    if withTemplate == .excelSpreadsheet {
      csvTableView.updateCSVData(with: url, withHeaderRowDetection: .largestNumberOfEntries)
    } else {
      csvTableView.updateCSVData(with: url)
    }
    // Enable FilterControl Sidebar
    enableToolbarButtonsOnFileLoad()
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
        self.sharedData.inputUserFile = fileUrl
        // TODO: Remove ImportFileTemplateSheet and FileTemplate
        let fileTemplate = FileTemplateParsing.detectFileTemplateType(fileUrl: url)
        self.presentImportFileTemplateSheet(url, withDetection: fileTemplate)
      }
    }
  }
  
}
