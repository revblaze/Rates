//
//  LaunchScreenData.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

extension ViewController {
  
  func fillLaunchTableViewWithExchangeRateData() {
    if let searchExchangeRateDataUrl = searchExchangeRateDataInDocumentsDirectory() {
      if let launchScreenCsvFileUrl = generateLaunchScreenData(fromCsvFileUrl: searchExchangeRateDataUrl) {
        passDataToTableView(fileUrl: launchScreenCsvFileUrl, withTemplate: .generic)
      }
    }
  }
  
  func generateLaunchScreenData(fromCsvFileUrl: URL) -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("Failed to get document directory URL")
      return nil
    }
    
    // Create the destination file URL
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
      
      // Join the sanitized lines into a new CSV string
      let launchScreenCSVString = sanitizedLines.joined(separator: "\n")
      
      // Write the new CSV string to the destination file
      try launchScreenCSVString.write(to: destinationFileURL, atomically: true, encoding: .utf8)
      
      // Return the destination file URL
      return destinationFileURL
    } catch {
      print("Failed to generate launch screen data")
      return nil
    }
  }
  
  func searchExchangeRateDataInDocumentsDirectory() -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("Failed to get document directory URL")
      return nil
    }
    
    // Perform recursive search in the documents directory
    if let fileURL = searchFile(named: "WS_XRU_D_csv_row.csv", in: documentDirectoryURL) {
      return fileURL
    } else {
      print("File not found")
      return nil
    }
  }
  
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
