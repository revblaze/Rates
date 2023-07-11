//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

extension ViewController {
  
  func presentImportFileTemplateSheet(_ fileUrl: URL, withDetection: FileTemplates) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    guard let importFileTemplateViewController = storyboard.instantiateController(withIdentifier: "ImportFileTemplateViewController") as? ImportFileTemplateViewController else {
      Debug.log("Unable to instantiate ImportFileTemplateViewController from storyboard")
      return
    }
    
    importFileTemplateViewController.fileUrl = fileUrl
    importFileTemplateViewController.withDetection = withDetection
    
    self.presentAsSheet(importFileTemplateViewController)
  }
  
  func passDataToTableView(fileUrl: URL, withTemplate: FileTemplates) {
    Debug.log("[passDataToTableView] withTemplate: \(withTemplate.rawValue) ")
    //MARK: UPDATE STATUS BAR
    
    // Step 1. Convert to CSV (without quotations)
    // Step 2. Modify for template
    
    // TODO: Remove quotations if every entry has them
    // TODO: Look for the first row with the longest avg entries and use that for header
    if let csvFileUrl = ConvertFile.toCSV(fileUrl: fileUrl) {
      
      if let restructuredCsvFileUrl = StructureFile.forTableView(csvFileUrl: csvFileUrl, withTemplate: withTemplate) {
        
        updateCSVTableViewWithCSV(at: restructuredCsvFileUrl, withTemplate: withTemplate)
        // TODO: Custom error handling?
        updateStatusBar(withState: .upToDate)
        
      }
      
    }
    
  }
  // MARK: Pass Data to TableView
  func updateCSVTableViewWithCSV(at url: URL, withTemplate: FileTemplates = .generic) {
    Debug.log("[updateCSVTableViewWithCSV] withTemplate: \(withTemplate.rawValue)")
    // Excel requires largest number of entries for header
    if withTemplate == .excelSpreadsheet {
      csvTableView.updateCSVData(with: url, withHeaderRowDetection: .largestNumberOfEntries)
    } else {
      csvTableView.updateCSVData(with: url)
    }
  }
  
  
  // MARK: File Browser Selection
  func openUserFile(completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    Debug.log(FileExtensions.all)
    openPanel.allowedFileTypes = FileExtensions.all //["csv", "tsv", "txt"]
    
    openPanel.begin { result in
      if result == NSApplication.ModalResponse.OK, let fileURL = openPanel.url {
        completion(fileURL)
      } else {
        completion(nil)
      }
    }
  }
  
  // Function to open file selection
  func openFileSelection() {
    openUserFile { fileURL in
      if let url = fileURL {
        let fileTemplate = FileTemplateParsing.detectFileTemplateType(fileUrl: url)
        self.presentImportFileTemplateSheet(url, withDetection: fileTemplate)
      }
    }
  }

  
}
