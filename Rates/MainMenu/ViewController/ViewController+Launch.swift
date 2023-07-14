//
//  ViewController+Launch.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// An extension of the `ViewController` class for handling the initial loading of the application.
extension ViewController {
  
  /// Initiates the launch process.
  ///
  /// Fills a table view with exchange rate data and updates the status bar. Checks if data needs updating
  /// and either fetches new data from the internet or uses local data if it's up-to-date.
  func beginLaunchSession() {
    fillLaunchTableViewWithExchangeRateData()
    
    updateStatusBar(withState: .loading)
    if dataNeedsUpdating() {
      checkInternetAndUpdateData()
    } else {
      checkLocalDataAndUpdateIfNecessary()
    }
  }
  
  /// Checks the internet connection and updates data accordingly.
  ///
  /// If there's no internet connection, it either shows a caution message (if a local database exists)
  /// or an error message (if no local database exists). If there's an internet connection, it starts
  /// downloading and converting CSV data to the database.
  func checkInternetAndUpdateData() {
    if noInternetConnection() {
      if localVersionOfDatabaseExists() {
        updateStatusBar(withState: .noConnectionAndPrefersUpdate)
      } else {
        updateStatusBar(withState: .noConnectionAndNoDb)
      }
    } else {
      updateStatusBar(withState: .isCurrentlyUpdating)
      startCsvDownloadAndConvertToDb()
    }
  }
  
  /// Checks if a local version of the database exists and updates the status bar and data accordingly.
  ///
  /// If a local version of the database exists, it updates the status bar to show the "Up to date" message.
  /// If a local version of the database does not exist, it checks the internet connection and updates data if necessary.
  func checkLocalDataAndUpdateIfNecessary() {
    if localVersionOfDatabaseExists() {
      updateStatusBar(withState: .upToDate)
    } else {
      checkInternetAndUpdateData()
    }
  }
  
  /// Checks if a local version of the database exists.
  ///
  /// - Returns: A boolean value indicating whether a local version of the database exists.
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
  
  /// Starts the downloading of the CSV file and its conversion to the database.
  ///
  /// If the database file is obtained successfully, it fills a table view with exchange rate data.
  /// If an error occurs, it updates the status bar to show a "Failed to update" message.
  func startCsvDownloadAndConvertToDb() {
    Task.detached {
      let exchangeRateData = ExchangeRateData()
      if let dbFileUrl = await exchangeRateData.getDb(fromUrl: Settings.defaultExchangeRatesUrlString) {
        Debug.log("Db file obtained: \(dbFileUrl)")
        await self.fillLaunchTableViewWithExchangeRateData()
        
      } else {
        Debug.log("Error occurred while awaiting getDb()")
        await self.updateStatusBar(withState: .failedToUpdate)
        
      }
    }
  }
  
  /// Checks if the data needs updating.
  ///
  /// - Returns: A boolean value indicating whether the data needs updating. If a new day has started,
  ///            it logs a message and returns `true`. If it's the same day, it logs a different message and returns `false`.
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
