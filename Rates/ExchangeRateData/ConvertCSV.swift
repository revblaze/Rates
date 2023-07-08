//
//  ConvertCSV.swift
//  Rates
//
//  Created by Justin Bush on 7/8/23.
//

import Foundation
import SQLite3

class ConvertCSV {
  
  func toSQLite(fileURL: URL) -> URL? {
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
