//
//  ViewController+ImportFile.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

extension ViewController {
  
  func presentImportFileTemplateSheet(_ fileUrl: URL, withDetection: FileTemplates) -> FileTemplates {
    let importFileTemplateView = ImportFileTemplateView(fileUrl: fileUrl, withDetection: withDetection)
    let window = NSApp.mainWindow
    
    guard let sheetWindow = window?.contentViewController?.view.window else {
      // Unable to get the sheet window
      return withDetection
    }
    
    let fileTemplates = importFileTemplateView.waitForDismissal(on: sheetWindow)
    return fileTemplates
  }
  
  func suggestDetectedFileTemplate(_ template: FileTemplates, forFileUrl: URL) {
    switch presentImportFileTemplateSheet(forFileUrl, withDetection: template) {
    case .generic:
      self.updateCSVTableViewWithCSV(at: forFileUrl)
    case .appStoreConnectSales:
      cleanAppStoreSalesFileAndPassToTableView(forFileUrl)
    }
  }
  
  
  // MARK: File Browser Selection
  func openUserFile(completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.allowedFileTypes = ["csv", "tsv", "txt"]
    
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
        let fileExtension = url.pathExtension.lowercased()
        
        if fileExtension == "csv" {
          Debug.log("Selected file is of type CSV")
          self.updateCSVTableViewWithCSV(at: url)
          
        } else if fileExtension == "tsv" {
          Debug.log("Selected file is of type TSV")
          self.handleTsvImport(fileURL: url)
          
        } else if fileExtension == "txt" {
          Debug.log("Selected file is of type TXT")
          self.handleTxtImport(fileURL: url)
          
        }
      }
    }
  }
  
  
  // MARK: Import File Handlers
  
  func handleTsvImport(fileURL: URL) {
    let convertTSV = ConvertTSV()
    if let csvFileURL = convertTSV.toCSV(fileURL: fileURL) {
      Debug.log("CSV file URL: \(csvFileURL)")
      self.updateCSVTableViewWithCSV(at: csvFileURL)
      
    } else {
      Debug.log("Failed to convert TSV to CSV.")
    }
  }
  
  
  func handleTxtImport(fileURL: URL) {
    
    switch FileTemplateParsing.detectFileTemplateType(fileUrl: fileURL) {
    case .appStoreConnectSales:
      Debug.log("handleTxtImport: .appStoreConnectSales")
      suggestDetectedFileTemplate(.appStoreConnectSales, forFileUrl: fileURL)
      
    case .generic:
      Debug.log("handleTxtImport: .generic")
      suggestDetectedFileTemplate(.generic, forFileUrl: fileURL)
    }
  }
  
  func cleanAppStoreSalesFileAndPassToTableView(_ fileUrl: URL) {
    if let cleanedFileUrl = FileTemplateParsing.cleanAppStoreFile(fileUrl: fileUrl) {
      Debug.log("Cleaned file created at: \(cleanedFileUrl)")
      passTSVtoCSVTableView(fileUrl: cleanedFileUrl)
    } else {
      Debug.log("Failed to clean the file.")
      return
    }
  }
  
  func passTSVtoCSVTableView(fileUrl: URL) {
    let convertTSV = ConvertTSV()
    if let csvFileURL = convertTSV.toCSV(fileURL: fileUrl) {
      Debug.log("CSV file URL: \(csvFileURL)")
      self.updateCSVTableViewWithCSV(at: csvFileURL)
      
    } else {
      Debug.log("Failed to convert TXT to CSV.")
    }
  }
  
  
}
