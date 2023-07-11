//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

extension ViewController {
  
//  func presentImportFileTemplateSheet(_ fileUrl: URL, withDetection: FileTemplates) -> FileTemplates {
//    let importFileTemplateView = ImportFileTemplateView(fileUrl: fileUrl, withDetection: withDetection)
//    let window = NSApp.mainWindow
//
//    guard let contentViewController = window?.contentViewController else {
//      // Unable to get the content view controller
//      return withDetection
//    }
//
//    contentViewController.presentAsSheet(importFileTemplateView)
//
//    return importFileTemplateView.waitForDismissal()
//  }
  
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
    
    
    // Step 1. Convert to CSV (without quotations)
    // Step 2. Modify for template
    
    // TODO: Remove quotations if every entry has them
    // TODO: Look for the first row with the longest avg entries and use that for header
    if let csvFileUrl = ConvertFile.toCSV(fileUrl: fileUrl) {
      
      if let restructuredCsvFileUrl = StructureFile.forTableView(csvFileUrl: csvFileUrl) {
        
        updateCSVTableViewWithCSV(at: restructuredCsvFileUrl)
        
      }
      
    }
    
  }
  
  
  
  func suggestDetectedFileTemplate(_ template: FileTemplates, forFileUrl: URL) {

    presentImportFileTemplateSheet(forFileUrl, withDetection: template)
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
  
  // MARK: New Pass Functions
//  func convertToCsvAndPassDataToTableView(fileUrl: URL) {
//    if let csvFileURL = ConvertTSV.toCSV(fileURL: fileUrl) {
//      Debug.log("CSV file URL: \(csvFileURL)")
//      updateCSVTableViewWithCSV(at: csvFileURL)
//
//    } else {
//      Debug.log("Failed to convert TSV to CSV.")
//    }
//  }
//  func cleanAppStoreSalesFileAndPassToTableView(_ fileUrl: URL) {
//    if let cleanedFileUrl = FileTemplateParsing.cleanAppStoreFile(fileUrl: fileUrl) {
//      Debug.log("Cleaned file created at: \(cleanedFileUrl)")
//      convertToCsvAndPassDataToTableView(fileUrl: cleanedFileUrl)
//    } else {
//      Debug.log("Failed to clean the file.")
//      return
//    }
//  }
  
  
  // MARK: Import File Handlers
  
//  func handleTsvImport(fileURL: URL) {
//    let convertTSV = ConvertTSV()
//    if let csvFileURL = convertTSV.toCSV(fileURL: fileURL) {
//      Debug.log("CSV file URL: \(csvFileURL)")
//      self.updateCSVTableViewWithCSV(at: csvFileURL)
//
//    } else {
//      Debug.log("Failed to convert TSV to CSV.")
//    }
//  }
//
//
//  func handleTxtImport(fileURL: URL) {
//
//    switch FileTemplateParsing.detectFileTemplateType(fileUrl: fileURL) {
//    case .appStoreConnectSales:
//      Debug.log("handleTxtImport: .appStoreConnectSales")
//      suggestDetectedFileTemplate(.appStoreConnectSales, forFileUrl: fileURL)
//
//    case .generic:
//      Debug.log("handleTxtImport: .generic")
//      suggestDetectedFileTemplate(.generic, forFileUrl: fileURL)
//    }
//  }
//
//
//
//  func passTSVtoCSVTableView(fileUrl: URL) {
//    let convertTSV = ConvertTSV()
//    if let csvFileURL = convertTSV.toCSV(fileURL: fileUrl) {
//      Debug.log("CSV file URL: \(csvFileURL)")
//      self.updateCSVTableViewWithCSV(at: csvFileURL)
//
//    } else {
//      Debug.log("Failed to convert TXT to CSV.")
//    }
//  }
  
  
}
