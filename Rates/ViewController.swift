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
    
    Task {
      // Create an instance of DownloadManagerSession
      let session = DownloadManagerSession()
      
      do {
        // Call the getExchangeRateData function using await
        let result = try await session.getExchangeRateData()
        // Handle the result
        print("Downloaded file URL: \(result)")
        
        do {
          let parseCsv = ParseCSV()
          let fileURL = result
          try parseCsv.clean(at: fileURL)
          print("Lines deleted successfully.")
        } catch {
          print("Error editing CSV file: \(error)")
        }
        
        
      } catch {
        // Handle errors
        print("Download failed: \(error)")
      }
    }
  }
  
  
  
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

