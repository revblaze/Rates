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
        print("Downloaded file URL: \(fileURL)")
        
        // Clean up CSV file
        let parseCsv = ParseCSV()
        try await parseCsv.clean(at: fileURL)
        print("Lines deleted successfully.")
        
        // Remove duplicate columns
        await parseCsv.removeDuplicateColumns(fileURL: fileURL)
        
        // Convert to SQLite db
        if let sqliteFileURL = await parseCsv.convertCSVtoSQLite(fileURL: fileURL) {
          print("SQLite file URL: \(sqliteFileURL)")
          // Update UI or perform any other necessary operations
        } else {
          print("Conversion failed.")
          // Update UI or perform any other necessary operations
        }
      } catch {
        print("Error: \(error)")
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

