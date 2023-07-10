//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

class ViewController: NSViewController {
  
  weak var delegate: FileSelectionDelegate?
  
  private var csvTableView: CSVTableView!
  private var scrollView: NSScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    scrollView = NSScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.width, .height]
    scrollView.hasVerticalScroller = true
    
    csvTableView = CSVTableView(frame: scrollView.bounds)
    csvTableView.autoresizingMask = [.width, .height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView)
  }
  
  override func viewDidAppear() {
    beginLaunchSession()
  }
  
  func revertTableViewChanges() {
    csvTableView.unhideColumns()
  }
  
  func filterAppStoreConnectSales() {
    csvTableView.filterAppStoreConnectSales()
  }
  
  func updateCSVTableViewWithCSV(at url: URL) {
    csvTableView.updateCSVData(with: url)
  }
  
  func beginLaunchSession() {
    
    if dataNeedsUpdating() {
      // TODO: IF NO INTERNET CONNECTION:
      // Display 'outdated' warning
      
      // TODO: Start download/loading animation
      startCsvDownloadAndConvertToDb()
      
    }
      
    else {
      if let dbFileUrl = findDataDBFileURL() {
        updateCSVTableViewWithCSV(at: dbFileUrl)
      } else {
        startCsvDownloadAndConvertToDb()
      }
        
    }
    // TODO: Stop animations
  }
  
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
  
  func startCsvDownloadAndConvertToDb() {
    Task.detached {
      let exchangeRateData = ExchangeRateData()
      if let dbFileUrl = await exchangeRateData.getDb(fromUrl: Settings.defaultExchangeRatesUrlString) {
        Debug.log("Db file obtained: \(dbFileUrl)")
        // TODO: Update UI?
        await self.updateCSVTableViewWithCSV(at: dbFileUrl)
        
      } else {
        Debug.log("Error occurred while awaiting getDb()")
        // TODO: Present error
      }
    }
  }
  
  func dataNeedsUpdating() -> Bool {
    if DailyCheck.shouldPerformAction() {
      Debug.log("[DailyCheck] New Day: download new exchange rate data")
      return true
    } else {
      Debug.log("[DailyCheck] Same Day: no action required")
      return false
    }
  }
  
  func findDataDBFileURL() -> URL? {
    do {
      let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
      // Filter fileURLs to find the file named "data.db"
      if let dataDBURL = fileURLs.first(where: { $0.lastPathComponent == "data.db" }) {
        return dataDBURL
      }
    } catch {
      print("Error while searching for data.db file: \(error)")
    }
      
    return nil
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}


extension ViewController {
  
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
