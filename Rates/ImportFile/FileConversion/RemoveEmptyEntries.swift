
//
//  RemoveEmptyEntries.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

/// A structure with a static method for removing the appending empty entries from CSV data.
struct RemoveEmptyEntries {
  
  /// Removes the appending empty entries from the CSV data.
  ///
  /// - Parameter csvData: The CSV data as a string.
  /// - Returns: The modified CSV data as a string, or `nil` if the method fails to find the row(s) with the most entries.
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
        
        // Check if the last entry of the row is either "––" or an empty space/empty entry
        if entries.count == maxEntryCount && (entries.last == "––" || entries.last?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) {
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
