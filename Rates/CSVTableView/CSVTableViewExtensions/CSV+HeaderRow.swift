//
//  CSV+HeaderRow.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation
import AppKit

/// Enumeration specifying the modes of detecting the header row in CSV data.
enum DetectHeaderRow {
  case firstRow, modeNumberOfEntries, largestNumberOfEntries, custom
}

/// Extension of the `CSVTableView` class to add additional methods for detecting the header row in CSV data.
extension CSVTableView {
  
  /// Finds the header row based on the mode of the number of entries in the CSV data.
  ///
  /// - Parameter tableData: The CSV data.
  /// - Returns: The header row.
  func findModeEntryHeaderRow(tableData: [[String]]) -> [String]? {
    var entryCountMap: [Int: Int] = [:] // [Entry count: Frequency]
    var maxFrequency = 0
    var filteredTableData: [[String]] = []
    
    for row in tableData {
      // If Constants.takesEmptyEntriesIntoAccount is false, decrement entryCount for each empty entry
      let filteredRow = Constants.takesEmptyEntriesIntoAccount ? row : row.filter { !$0.isEmpty }
      let entryCount = filteredRow.count
      entryCountMap[entryCount, default: 0] += 1
      maxFrequency = max(maxFrequency, entryCountMap[entryCount] ?? 0)
      filteredTableData.append(filteredRow)
    }
    
    let modeEntryCounts = entryCountMap.filter { $0.value == maxFrequency }.map { $0.key }
    let modeRows = filteredTableData.filter { modeEntryCounts.contains($0.count) }
    
    return modeRows.first
  }
  
  /// Finds the header row with the largest number of entries in the CSV data.
  ///
  /// - Parameter tableData: The CSV data.
  /// - Returns: The header row.
  func findLargestNumberEntryHeaderRow(tableData: [[String]]) -> [String]? {
    // Step 1: Filter out the empty strings from each row
    let filteredTableData = tableData.map { $0.filter { !$0.isEmpty } }
    
    // Step 2: Find the rows with the highest count of non-empty strings
    let maxCount = filteredTableData.max { $0.count < $1.count }?.count ?? 0
    let largestRows = filteredTableData.filter { $0.count == maxCount }
    
    Debug.log("largestRows: \(largestRows)")
    
    
    // Step 3: Return the first of those rows
    return largestRows.first
  }

  
  /// Retrieves the cell text of the very first row from the provided table data.
  ///
  /// This function checks the first row of the provided two-dimensional string array (representing table data) and returns it as an array of strings.
  /// These strings represent the cell text of the first row, which typically serve as headers in a table data structure.
  /// If the provided table data is empty, the function will return `nil`.
  ///
  /// - Parameter tableData: A two-dimensional array of strings representing the table data.
  ///
  /// - Returns: An array of strings representing the cell text of the first row of the provided table data, or `nil` if the table data is empty.
  func getFirstRowHeaders(from tableData: [[String]]) -> [String]? {
    guard !tableData.isEmpty else {
      return nil
    }

    return tableData[0]
  }
  
}
