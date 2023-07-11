//
//  RemoveEmptyEntries.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

struct RemoveEmptyEntries {
  
  static func removeAppendingEmptyEntries(csvData: String) -> String? {
    // Split the CSV data into rows
    var rows = csvData.components(separatedBy: "\n")
    
    // Find the row(s) with the most entries
    guard let maxEntryCount = rows.map({ $0.components(separatedBy: ",") }).max(by: { $0.count < $1.count })?.count else {
      return nil
    }
    
    var shouldContinue = true
    
    while shouldContinue {
      shouldContinue = false
      
      // Loop through rows with the maximum entry count
      for (index, row) in rows.enumerated() {
        let entries = row.components(separatedBy: ",")
        
        // Check if the last entry of the row contains "––"
        if entries.count == maxEntryCount && entries.last == "––" {
          // Remove the last entry from the row
          let updatedRow = entries.dropLast().joined(separator: ",")
          rows[index] = updatedRow
          
          // Set the flag to continue the loop
          shouldContinue = true
        }
      }
    }
    
    // Join the modified rows back into CSV data
    let modifiedCSV = rows.joined(separator: "\n")
    
    return modifiedCSV
  }
  
}
