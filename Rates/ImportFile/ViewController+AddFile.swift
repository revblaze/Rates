//
//  ViewController+AddFile.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

extension ViewController {
  
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
      if let cleanedFileUrl = FileTemplateParsing.cleanAppStoreFile(fileUrl: fileURL) {
        Debug.log("Cleaned file created at: \(cleanedFileUrl)")
        passTSVtoCSVTableView(fileUrl: cleanedFileUrl)
      } else {
        Debug.log("Failed to clean the file.")
        return
      }
    case .generic:
      Debug.log("handleTxtImport: .generic File")
      // TODO: Handle generic files
      passTSVtoCSVTableView(fileUrl: fileURL)
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
