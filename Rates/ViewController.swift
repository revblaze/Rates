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
  
  var statusBarState: StatusBarState? = .loading
  @IBOutlet weak var statusBarButton: NSButton!
  @IBOutlet weak var statusBarText: NSTextField!
  @IBOutlet weak var statusBarProgressBar: NSProgressIndicator!
  var statusBarButtonIsPulsing = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    scrollView = NSScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.width, .height]
    scrollView.hasVerticalScroller = true
    
    csvTableView = CSVTableView(frame: scrollView.bounds)
    csvTableView.autoresizingMask = [.width, .height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: nil)
  }
  
  override func viewDidAppear() {
    beginLaunchSession()
  }
  
  // MARK: TableView Filters
  func revertTableViewChanges() {
    csvTableView.unhideColumns()
  }
  func filterAppStoreConnectSales() {
    csvTableView.filterAppStoreConnectSales()
  }
  // MARK: Pass Data to TableView
  func updateCSVTableViewWithCSV(at url: URL) {
    csvTableView.updateCSVData(with: url)
    updateStatusBar(withState: .upToDate)
  }
  
  // MARK: Perform at Launch
  func beginLaunchSession() {
    updateStatusBar(withState: .loading)
    // If a day has passed since last updating the exchange rate data
    if dataNeedsUpdating() {
      checkInternetAndUpdateData()
    }
    // Else, data does not need updating
    else {
      // And database exists
      if localVersionOfDatabaseExists() {
        // Update status bar with "Up to date"
        updateStatusBar(withState: .upToDate)
      }
      // Else, if data does not exist
      else {
        checkInternetAndUpdateData()
      }
    }
  }
  
  func checkInternetAndUpdateData() {
    // If there is no internet connection
    if noInternetConnection() {
      // But there does exist a local database
      if localVersionOfDatabaseExists() {
        // Update status bar to show caution message
        updateStatusBar(withState: .noConnectionAndPrefersUpdate)
      } else {
        // Else, no internet or db > error message
        updateStatusBar(withState: .noConnectionAndNoDb)
      }
    }
    // Else, there is internet
    else {
      // Start download and conversion
      updateStatusBar(withState: .isCurrentlyUpdating)
      startCsvDownloadAndConvertToDb()
    }
  }
  
  func localVersionOfDatabaseExists() -> Bool {
    let fileManager = FileManager.default
    let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
      let directoryContents = try fileManager.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      
      if directoryContents.isEmpty || !directoryContents.contains(where: { $0.lastPathComponent == "data.db" }) {
        Debug.log("Documents directory is empty or does not contain 'data.db'")
      } else {
        Debug.log("Documents directory is not empty and contains 'data.db'")
        return true
      }
    } catch {
      Debug.log("Error accessing documents directory: \(error)")
    }
    return false
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
        await self.updateStatusBar(withState: .failedToUpdate)
        
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
  
  
  
}
