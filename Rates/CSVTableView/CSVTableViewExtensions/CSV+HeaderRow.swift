//
//  CSV+HeaderRow.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

/// Enumeration specifying the modes of detecting the header row in CSV data.
enum DetectHeaderRow {
  case modeNumberOfEntries, largestNumberOfEntries, custom
}

/// Extension of the `CSVTableView` class to add additional methods for detecting the header row in CSV data.
extension CSVTableView {
  
  /// Finds the header row based on the mode of the number of entries in the CSV data.
  ///
  /// - Parameter tableData: The CSV data.
  /// - Returns: The header row.
  static func findModeEntryHeaderRow(tableData: [[String]]) -> [String]? {
    var entryCountMap: [Int: Int] = [:] // [Entry count: Frequency]
    var maxFrequency = 0

    for row in tableData {
      let entryCount = row.count
      entryCountMap[entryCount, default: 0] += 1
      maxFrequency = max(maxFrequency, entryCountMap[entryCount] ?? 0)
    }

    let modeEntryCounts = entryCountMap.filter { $0.value == maxFrequency }.map { $0.key }
    let modeRows = tableData.filter { modeEntryCounts.contains($0.count) }

    return modeRows.first
  }

  /// Finds the header row with the largest number of entries in the CSV data.
  ///
  /// - Parameter tableData: The CSV data.
  /// - Returns: The header row.
  static func findLargestNumberEntryHeaderRow(tableData: [[String]]) -> [String]? {
    var headerRow: [String]? = nil
    var maxEntryCount = 0

    for row in tableData {
      let entryCount = row.count
      if entryCount > maxEntryCount {
        maxEntryCount = entryCount
        headerRow = row
      }
    }

    return headerRow
  }
  
}
