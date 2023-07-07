//
//  ParseCSV.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation
import SwiftCSV
import SQLite3

class ParseCSV {
  
  func clean(at fileURL: URL, cutOffDate: String = "2016-01-01") throws {
    // Read the file contents
    let fileContents = try String(contentsOf: fileURL)
    
    // Split the file contents into individual lines
    var lines = fileContents.components(separatedBy: .newlines)
    
    // Substrings to check for at the beginning of lines
    let substringsToDelete = [
      "\"Frequency\"",
      "\"Reference area\"",
      "\"Collection\"",
      "\"Unit Multiplier\"",
      "\"Decimals\"",
      "\"Availability\"",
      "\"Title\"",
      "\"Time Period\""
    ]
    
    // Iterate through the lines and delete those starting with specified substrings
    lines.removeAll { line in
      substringsToDelete.contains { line.hasPrefix($0) }
    }
    
    // Replace substrings between ":" and "\"" on the line starting with "\"Currency\""
    if let currencyIndex = lines.firstIndex(where: { $0.hasPrefix("\"Currency\"") }) {
      var currencyLine = lines[currencyIndex]
      let components = currencyLine.components(separatedBy: ",")
      let modifiedArray = components.map { element -> String in
        let modifiedElement = element.replacingOccurrences(of: ":.*?\"", with: "\"", options: .regularExpression)
        return modifiedElement
      }
      
      let combinedString = modifiedArray.joined(separator: ",")
      
      currencyLine = combinedString
      
      // Replace the original line with the updated line
      lines[currencyIndex] = currencyLine
    }
    
    // Reverse lines from the second line to the last line
    if lines.count > 1 {
      let startIndex = 1
      let endIndex = lines.count - 1
      let reversedLines = Array(lines[startIndex...endIndex].reversed())
      lines.replaceSubrange(startIndex...endIndex, with: reversedLines)
    }
    
    // Find the index of the first row containing the cutOffDate substring
    if let rowIndex = lines.firstIndex(where: { $0.contains(cutOffDate) }) {
      // Remove rows below rowIndex (including rowIndex)
      lines.removeSubrange((rowIndex + 1)...)
    }
    
    // Reconstruct the updated contents
    let updatedContents = lines.joined(separator: "\n")
    
    // Write the updated contents back to the file
    try updatedContents.write(to: fileURL, atomically: true, encoding: .utf8)
  }
  
  func removeDuplicateColumns(fileURL: URL) {
    do {
      // Read the content of the CSV file
      let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
      
      // Split the file content into lines
      var lines = fileContent.components(separatedBy: .newlines)
      
      // Extract the header row
      guard let headerRow = lines.first else {
        print("Empty file")
        return
      }
      
      // Split the header row into columns
      var headers = headerRow.components(separatedBy: ",")
      
      // Track the duplicate header names
      var duplicateColumns = Set<String>()
      
      // Iterate through the header columns
      var columnIndicesToRemove = [Int]()
      for (index, header) in headers.enumerated() {
        if duplicateColumns.contains(header) {
          // Mark the duplicate header column index for removal
          columnIndicesToRemove.append(index)
        } else {
          duplicateColumns.insert(header)
        }
      }
      
      // Remove the duplicate header columns and corresponding data
      columnIndicesToRemove.reversed().forEach { indexToRemove in
        headers.remove(at: indexToRemove)
        lines = lines.map { line in
          var columns = line.components(separatedBy: ",")
          
          if indexToRemove < columns.count {
            columns.remove(at: indexToRemove)
          }
          
          return columns.joined(separator: ",")
        }
      }
      
      // Generate the new CSV content without duplicate columns
      let newContent = headers.joined(separator: ",") + "\n" + lines.joined(separator: "\n")
      
      // Write the updated content back to the file
      try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
      
      print("Duplicate columns and corresponding data removed successfully.")
      
    } catch {
      print("Error reading the file: \(error.localizedDescription)")
    }
  }
  
  
  // MARK: Convert CSV to SQLite (db)
  
  func convertCSVtoSQLite(fileURL: URL) -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("Failed to get document directory URL")
      return nil
    }
    
    // Create the SQLite database file URL in the document directory
    let sqliteFileURL = documentDirectoryURL.appendingPathComponent("data.db")
    
    // Open SQLite database connection
    var db: OpaquePointer?
    if sqlite3_open(sqliteFileURL.path, &db) != SQLITE_OK {
      print("Failed to open database")
      return nil
    }
    
    // Read the CSV file
    do {
      let csvString = try String(contentsOf: fileURL, encoding: .utf8)
      let csvRows = csvString.components(separatedBy: "\n")
      
      // Create SQLite table based on the CSV header
      if let header = csvRows.first {
        let createTableStatement = "CREATE TABLE IF NOT EXISTS data (\(header));"
        if sqlite3_exec(db, createTableStatement, nil, nil, nil) != SQLITE_OK {
          print("Failed to create table")
          return nil
        }
      }
      
      // Insert data from the CSV file
      for row in csvRows.dropFirst() {
        let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRow.isEmpty else {
          continue // Skip empty rows
        }
        
        let insertStatement = "INSERT INTO data VALUES (\(row));"
        if sqlite3_exec(db, insertStatement, nil, nil, nil) != SQLITE_OK {
          print("Failed to insert row: \(row)")
          return nil
        }
      }
      
      // Close the SQLite database connection
      sqlite3_close(db)
      
      // Return the SQLite database file URL in the document directory
      return sqliteFileURL
    } catch {
      print("Failed to read CSV file")
      return nil
    }
  }
  
}
