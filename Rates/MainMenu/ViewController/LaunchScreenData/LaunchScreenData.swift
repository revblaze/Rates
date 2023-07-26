//
//  LaunchScreenData.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// Extension of the `ViewController` class to add additional methods for handling launch screen data.
extension ViewController {
  
  func launchScreenDataDidFinishLoading() {
    updateAvailableCurrencyCodeHeaders()
    sharedData.sqliteUrl = Query.sqliteUrl()
    windowController?.enableToolbarItemsOnLaunchDataLoad()
    // Enable just in case
    enableMainViewInteraction()
    
    Debug.log("[launchScreenDataDidFinishLoading] Done.")
    tableIsPopulatedWithLaunchScreenData = true
    
    appDelegate.mainViewDidAppearAndIsReadyForInteraction = true
  }
  
  /// Updates the CSV table view with launch data from a given URL.
  ///
  /// - Parameter url: The URL of the launch data.
  func updateCSVTableViewWithLaunchData(at url: URL) {
    Debug.log("[updateCSVTableViewWithLaunchData]")
    
    if userDidOpenFileWithFinderAndWillPassToTableView() {
      Debug.log("[updateCSVTableViewWithLaunchData] User opened file with Finder. Skipping launch setup.")
      userHasPreviouslyLoadedInputFileThisSession = true
      
    } else if !csvTableView.tableData.isEmpty {
      // If table view already contains data, skip any extra setup.
      Debug.log("[updateCSVTableViewWithLaunchData] Table already contains data. Skipping launch setup.")
      userHasPreviouslyLoadedInputFileThisSession = true
      
      
    } else if sharedSettings.showExchangeRateDataOnLaunch {
      // If showExchangeRateData on launch, update tableData with launchScreenData.csv
      csvTableView.updateCSVData(with: url, withHeaderRowDetection: .firstRow)
    } else {
      // Else, show FileDropBox view
      showFileDropBox()
    }
    
    // TODO: Double check/test disableMainViewInteraction()
    updateStatusBar(withState: .upToDate)
    launchScreenDataDidFinishLoading()
  }

  /// Fills the launch table view with exchange rate data.
  func fillLaunchTableViewWithExchangeRateData() {
    // Check if the launch screen data already exists
    if let existingLaunchDataUrl = Utility.searchDocumentsDirectory(forFileName: "launchScreenData.csv") {
      DispatchQueue.main.async { [weak self] in
        self?.updateCSVTableViewWithLaunchData(at: existingLaunchDataUrl)
      }
    } else if let searchExchangeRateDataUrl = Utility.searchDocumentsDirectory(forFileName: Constants.csvExchangeRateDataFileName),
              let launchScreenCsvFileUrl = generateLaunchScreenData(fromCsvFileUrl: searchExchangeRateDataUrl) {
      // If the launch screen data does not exist, generate new data from the exchange rate data
      DispatchQueue.main.async { [weak self] in
        self?.updateCSVTableViewWithLaunchData(at: launchScreenCsvFileUrl)
      }
    } else {
      // If neither the existing nor the new data can be found or generated, print an error message and return
      Debug.log("[fillLaunchTableViewWithExchangeRateData] Could not find or generate launch screen data")
    }
  }
  
  /// Generates launch screen data from a CSV file at a given URL.
  ///
  /// - Parameter fromCsvFileUrl: The URL of the CSV file.
  /// - Returns: The URL of the generated launch screen data, or `nil` if the generation failed.
  func generateLaunchScreenData(fromCsvFileUrl: URL) -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Failed to get document directory URL")
      return nil
    }
    
    let destinationFileURL = documentDirectoryURL.appendingPathComponent("launchScreenData.csv")
    
    // Read the input CSV file
    do {
      let csvString = try String(contentsOf: fromCsvFileUrl, encoding: .utf8)
      
      // Split the CSV string into lines
      var lines = csvString.components(separatedBy: .newlines)
      
      // Replace "Currency" with "Date" in the first line
      if lines.indices.contains(0) {
        lines[0] = lines[0].replacingOccurrences(of: "Currency", with: "Date")
      }
      
      // Remove the entire second line
      if lines.indices.contains(1) {
        lines.remove(at: 1)
      }
      
      // Take the first 50 lines
      let launchScreenLines = Array(lines.prefix(80))
      
      // Remove quotation marks from each line
      let sanitizedLines = launchScreenLines.map { line in
        return line.replacingOccurrences(of: "\"", with: "")
      }
      
      // Replace "NaN" with "––" in each line
      let replacedNanLines = sanitizedLines.map { line in
        return line.replacingOccurrences(of: "NaN", with: Constants.replaceNanLinesInLaunchData)
      }
      
      let replacedLines = replacedNanLines.map { line in
        let firstRound = line.replacingOccurrences(of: ",,", with: ",\(Constants.replaceEmptyLinesInLaunchData),")
        return firstRound.replacingOccurrences(of: ",,", with: ",\(Constants.replaceEmptyLinesInLaunchData),")
      }
      
      // Join the sanitized lines into a new CSV string
      let launchScreenCSVString = replacedLines.joined(separator: "\n")
      
      // Write the new CSV string to the destination file
      try launchScreenCSVString.write(to: destinationFileURL, atomically: true, encoding: .utf8)
      
      // Return the destination file URL
      return destinationFileURL
    } catch {
      Debug.log("Failed to generate launch screen data")
      return nil
    }
  }
  
  /// Searches for exchange rate data in the documents directory.
  ///
  /// - Returns: The URL of the exchange rate data, or `nil` if the search failed.
  func searchExchangeRateDataInDocumentsDirectory() -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Failed to get document directory URL")
      return nil
    }
    
    // Perform recursive search in the documents directory
    if let fileUrl = searchFile(named: "WS_XRU_D_csv_row.csv", in: documentDirectoryURL) {
      return fileUrl
    } else {
      Debug.log("[searchExchangeRateDataInDocumentsDirectory] File not found")
      return nil
    }
  }
  
  /// Searches for exchange rate data in the documents directory.
  ///
  /// - Returns: The URL of the exchange rate data, or `nil` if the search failed.
  func searchFile(named fileName: String, in directoryURL: URL) -> URL? {
    // Get the contents of the directory
    let fileManager = FileManager.default
    let contents = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
    
    for url in contents ?? [] {
      if url.hasDirectoryPath {
        // Recursive call for subdirectories
        if let foundURL = searchFile(named: fileName, in: url) {
          return foundURL
        }
      } else if url.lastPathComponent == fileName {
        // File found
        return url
      }
    }
    
    // File not found
    return nil
  }
  
}
