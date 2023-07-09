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

protocol FilterDelegate: class {
    func filterAppStoreConnectSales()
}

class ViewController: NSViewController, FilterDelegate {
  
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
  
  func updateCSVTableViewWithCSV(at url: URL) {
    csvTableView.updateCSVData(with: url)
  }
  
  func filterAppStoreConnectSales() {
    print("Made it to filterAppStoreConnectSales")
    csvTableView.filterAppStoreConnectSales()
  }
  
  
  
  // Function to open file selection
  func openFileSelection() {
    openUserFile { fileURL in
      if let url = fileURL {
        // Call the delegate method with the selected file URL
        //self.delegate?.fileSelected(self, fileURL: url)
        self.updateCSVTableViewWithCSV(at: url)
      }
    }
  }
  
  func openUserFile(completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.allowedFileTypes = ["csv"]
    
    openPanel.begin { result in
      if result == NSApplication.ModalResponse.OK, let fileURL = openPanel.url {
        completion(fileURL)
      } else {
        completion(nil)
      }
    }
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
  
  func startCsvDownloadAndConvertToDb() {
    Task.detached {
      let exchangeRateData = ExchangeRateData()
      if let dbFileUrl = await exchangeRateData.getDb(fromUrl: Settings.defaultExchangeRatesUrlString) {
        Debug.log("Db file obtained: \(dbFileUrl)")
        // TODO: Update UI?
        await self.updateCSVTableViewWithCSV(at: dbFileUrl)
        
      } else {
        Debug.log("Error occured while awaiting getDb()")
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

