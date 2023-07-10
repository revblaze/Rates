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
    
    switch withTemplate {
    // MARK: App Store Sales Templates
    case .appStoreConnectSales:
      if fileUrl.hasFileExtension() == .txt || fileUrl.hasFileExtension() == .tsv {
        cleanAppStoreSalesFileAndPassToTableView(fileUrl)
      } else if fileUrl.hasFileExtension() == .csv {
        updateCSVTableViewWithCSV(at: fileUrl)
      } else {
        Debug.log("[passDataToTableView] .appStore error for file: \(fileUrl)")
      }
    // MARK: Generic Template
    case .generic:
      if fileUrl.hasFileExtension() == .csv {
        updateCSVTableViewWithCSV(at: fileUrl)
      } else {
        convertToCsvAndPassDataToTableView(fileUrl: fileUrl)
      }
      
      
    }
    
    
  }
  
  func suggestDetectedFileTemplate(_ template: FileTemplates, forFileUrl: URL) {
//      switch presentImportFileTemplateSheet(forFileUrl, withDetection: template) {
//      case .generic:
//        self.updateCSVTableViewWithCSV(at: forFileUrl)
//      case .appStoreConnectSales:
//        cleanAppStoreSalesFileAndPassToTableView(forFileUrl)
//      }
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
        
        var detectedFileTemplate = FileTemplates.generic
        
        switch url.hasFileExtension() {
        case .csv:
          // generic
          break
            
        case .tsv:
          if FileTemplateParsing.containsAppStoreConnectHeaders(fileUrl: url) {
            detectedFileTemplate = .appStoreConnectSales
          }
          
        case .txt:
          if FileTemplateParsing.containsAppStoreConnectHeaders(fileUrl: url) {
            detectedFileTemplate = .appStoreConnectSales
          }
          
        case .none:
          // generic
          Debug.log("[openFileSelection] error: unknown file type")
        }
        
        self.presentImportFileTemplateSheet(url, withDetection: detectedFileTemplate)
        
      }
    }
  }
  
  // MARK: New Pass Functions
  func convertToCsvAndPassDataToTableView(fileUrl: URL) {
    let convertTSV = ConvertTSV()
    if let csvFileURL = convertTSV.toCSV(fileURL: fileUrl) {
      Debug.log("CSV file URL: \(csvFileURL)")
      updateCSVTableViewWithCSV(at: csvFileURL)
      
    } else {
      Debug.log("Failed to convert TSV to CSV.")
    }
  }
  func cleanAppStoreSalesFileAndPassToTableView(_ fileUrl: URL) {
    if let cleanedFileUrl = FileTemplateParsing.cleanAppStoreFile(fileUrl: fileUrl) {
      Debug.log("Cleaned file created at: \(cleanedFileUrl)")
      convertToCsvAndPassDataToTableView(fileUrl: cleanedFileUrl)
    } else {
      Debug.log("Failed to clean the file.")
      return
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
