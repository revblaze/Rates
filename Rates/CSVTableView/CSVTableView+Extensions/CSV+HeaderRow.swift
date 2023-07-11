//
//  CSV+HeaderRow.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

enum DetectHeaderRow {
  case modeNumberOfEntries, largestNumberOfEntries
}

extension CSVTableView {
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
