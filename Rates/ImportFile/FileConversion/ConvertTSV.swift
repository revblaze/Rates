//
//  ConvertTSV.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

struct ConvertTSV {
  
  static func toCSV(fileURL: URL) -> URL? {
    let fileManager = FileManager.default
    
    // Create a destination URL for the CSV file
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    
    let randomString = String((0..<5).map { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
    let csvFileName = "tabs_\(randomString).csv"
    let csvURL = documentsDirectory.appendingPathComponent(csvFileName)
    
    do {
      // Read the contents of the TSV file
      let tsvData = try Data(contentsOf: fileURL)
      
      // Convert TSV data to a CSV string
      guard let tsvString = String(data: tsvData, encoding: .utf8) else {
        return nil
      }
      
      // Replace empty entries with "––"
      
      let csvString = tsvString.replacingOccurrences(of: "\t", with: ",")//.replacingOccurrences(of: "\t\t", with: ",––,")
        .replacingOccurrences(of: ",,", with: ",––,")
        .replacingOccurrences(of: ",\n", with: ",––\n")
        .replacingOccurrences(of: "\n,", with: "\n––,")
        .replacingOccurrences(of: "\n\n", with: "\n––\n")
      
      // Write the CSV string to the destination URL
      try csvString.write(to: csvURL, atomically: true, encoding: .utf8)
      
      return csvURL
    } catch {
      Debug.log("Error converting TSV to CSV: \(error)")
      return nil
    }
  }
  
}
