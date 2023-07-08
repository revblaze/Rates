//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

class ViewController: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear() {
    
    beginDataDownloadSession()
    
  }
  
  func beginDataDownloadSession() {
    Task.detached {
      do {
        // Create an instance of DownloadManagerSession and get the downloaded file URL
        let session = DownloadManagerSession()
        let fileURL = try await session.getExchangeRateData()
        Debug.log("Downloaded file URL: \(fileURL)")
        
        // Clean up CSV file
        let parseCsv = ParseCSV()
        try parseCsv.clean(at: fileURL)
        Debug.log("Lines deleted successfully.")
        
        // Remove duplicate columns
        parseCsv.removeDuplicateColumns(fileURL: fileURL)
        
        // Convert to SQLite db
        let convertCsv = ConvertCSV()
        if let sqliteFileURL = convertCsv.toSQLite(fileURL: fileURL) {
          Debug.log("SQLite file URL: \(sqliteFileURL)")
          // Update UI or perform any other necessary operations
        } else {
          Debug.log("Conversion failed.")
          // Update UI or perform any other necessary operations
        }
      } catch {
        Debug.log("Error: \(error)")
        // Update UI or perform any other necessary operations
      }
    }
  }
  
  
  
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

