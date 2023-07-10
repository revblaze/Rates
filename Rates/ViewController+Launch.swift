//
//  ViewController+Launch.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

extension ViewController {
  
  // MARK: Perform at Launch
  
  func beginLaunchSession() {
    fillLaunchTableViewWithExchangeRateData()
    
    updateStatusBar(withState: .loading)
    // If a day has passed since last updating the exchange rate data
    if dataNeedsUpdating() {
      checkInternetAndUpdateData()
    }
    // Else, data does not need updating
    else {
      checkLocalDataAndUpdateIfNecessary()
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
  
  func checkLocalDataAndUpdateIfNecessary() {
    // If local database exists
    if localVersionOfDatabaseExists() {
      // Update status bar with "Up to date"
      updateStatusBar(withState: .upToDate)
    }
    // Else, if data does not exist
    else {
      checkInternetAndUpdateData()
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
        //await self.updateCSVTableViewWithCSV(at: dbFileUrl)
        await self.fillLaunchTableViewWithExchangeRateData()
        
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
  
}
