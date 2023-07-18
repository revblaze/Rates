//
//  ConvertTSV.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

/// A structure with a static method for converting a TSV (Tab-Separated Values) file to a CSV (Comma-Separated Values) file.
struct ConvertTSV {
  
  /// Converts a TSV file to a CSV file.
  ///
  /// - Parameter fileUrl: The URL of the TSV file.
  /// - Returns: The URL of the CSV file, or `nil` if an error occurs during the conversion.
  static func toCSV(fileUrl: URL) -> URL? {
    let fileManager = FileManager.default
    
    // Create a destination URL for the CSV file
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    
    let randomString = Utility.randomString(length: 5)
    let csvFileName = "tabs_\(randomString).csv"
    let csvURL = documentsDirectory.appendingPathComponent(csvFileName)
    
    do {
      // Read the contents of the TSV file
      let tsvData = try Data(contentsOf: fileUrl)
      
      // Convert TSV data to a CSV string
      guard let tsvString = String(data: tsvData, encoding: .utf8) else {
        return nil
      }
      
      let replaceTabbedEntries = tsvString.replacingOccurrences(of: "\t", with: ",")
        .replacingOccurrences(of: ",,", with: ",––,")
        .replacingOccurrences(of: ",\n", with: ",––\n")
        .replacingOccurrences(of: "\n,", with: "\n––,")
        .replacingOccurrences(of: "\n\n", with: "\n––\n")
      
      var replaceEmptyEntries = replaceTabbedEntries
      
      while replaceEmptyEntries.contains(",,") {
        let replacedEntries = replaceEmptyEntries.replacingOccurrences(of: ",,", with: ",––,")
          .replacingOccurrences(of: ",\n", with: ",––\n")
          .replacingOccurrences(of: "\n,", with: "\n––,")
          .replacingOccurrences(of: "\n\n", with: "\n––\n")
        replaceEmptyEntries = replacedEntries
      }
      
      var csvString = replaceEmptyEntries
      
      if let slimData = RemoveEmptyEntries.removeAppendingEmptyEntries(csvData: csvString) {
        csvString = slimData
      } else {
        Debug.log("[ConvertTSV.toCSV] Unable to slimData")
      }
      
      // Write the CSV string to the destination URL
      try csvString.write(to: csvURL, atomically: true, encoding: .utf8)
      return csvURL
      
    } catch {
      Debug.log("[ConvertTSV.toCSV] Error converting TSV to CSV: \(error)")
      return nil
    }
  }
  
}
