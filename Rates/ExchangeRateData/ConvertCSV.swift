
//
//  ConvertCSV.swift
//  Rates
//
//  Created by Justin Bush on 7/8/23.
//

import Foundation
import SQLite3

/// A class with a method for converting a CSV file to an SQLite database.
class ConvertCSV {
  
  /// Converts a CSV file to an SQLite database.
  ///
  /// - Parameter fileUrl: The URL of the CSV file.
  /// - Returns: The URL of the SQLite database file, or `nil` if an error occurs during the process.
  func toSQLite(fileUrl: URL) -> URL? {
    // Get the document directory URL
    guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("[ConvertCSV.toSQLite] Failed to get document directory URL")
      return nil
    }
    
    // Create the SQLite database file URL in the document directory
    let sqliteFileUrl = documentDirectoryUrl.appendingPathComponent(Constants.sqliteFileName)
    
    // Open SQLite database connection
    var db: OpaquePointer?
    if sqlite3_open(sqliteFileUrl.path, &db) != SQLITE_OK {
      Debug.log("[ConvertCSV.toSQLite] Failed to open database")
      return nil
    }
    
    // Read the CSV file
    do {
      let csvString = try String(contentsOf: fileUrl, encoding: .utf8)
      var modifiedCsvString = csvString
      if let range = csvString.range(of: "Currency") {
        modifiedCsvString = csvString.replacingOccurrences(of: "Currency", with: Constants.sqliteDateColumnValue, options: [], range: range)
      }
      
      let csvRows = modifiedCsvString.components(separatedBy: "\n")
      
      // Create SQLite table based on the CSV header
      if let header = csvRows.first {
        let createTableStatement = "CREATE TABLE IF NOT EXISTS data (\(header));"
        if sqlite3_exec(db, createTableStatement, nil, nil, nil) != SQLITE_OK {
          Debug.log("[ConvertCSV.toSQLite] Failed to create table")
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
          Debug.log("[ConvertCSV.toSQLite] Failed to insert row: \(row)")
          return nil
        }
      }
      
      // Close the SQLite database connection
      sqlite3_close(db)
      
      // Return the SQLite database file URL in the document directory
      return sqliteFileUrl
    } catch {
      Debug.log("[ConvertCSV.toSQLite] Failed to read CSV file")
      return nil
    }
  }
  
}
