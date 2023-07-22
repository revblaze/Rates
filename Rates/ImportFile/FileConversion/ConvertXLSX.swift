//
//  ConvertXLSX.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation
import CoreXLSX

/// A structure with a static method for converting an XLSX (Excel) file to a CSV (Comma-Separated Values) file.
struct ConvertXLSX {
  
  /// Converts an XLSX file to a CSV file.
  ///
  /// - Parameter fileUrl: The URL of the XLSX file.
  /// - Returns: The URL of the CSV file, or `nil` if an error occurs during the conversion.
  static func toCSV(fileUrl: URL) -> URL? {
    do {
      guard let file = XLSXFile(filepath: fileUrl.path) else {
        fatalError("XLSX file at \(fileUrl.path) is corrupted or does not exist")
      }
      
      var csvData = ""
      
      for workbook in try file.parseWorkbooks() {
        for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
          if let worksheetName = name {
            Debug.log("[ConvertXLSX.toCSV] This worksheet has a name: \(worksheetName)")
          }
          
          let worksheet = try file.parseWorksheet(at: path)
          for row in worksheet.data?.rows ?? [] {
            let rowData = row.cells.compactMap { cell -> String? in
              do {
                if let sharedStrings = try file.parseSharedStrings() {
                  if let value = cell.stringValue(sharedStrings) {
                    return "\(value)"
                  } else if let date = cell.dateValue {
                    return "\(date)"
                  } else if let formula = cell.formula {
                    return "\(formula)"
                  } else if let inlineString = cell.inlineString {
                    return "\(inlineString)"
                  } else if let richStringValue = cell.richStringValue(sharedStrings) {
                    return richStringValue.compactMap { $0.text }.joined(separator: " ")
                  } else if let cellValue = cell.value {
                    return "\(cellValue)"
                  } else {
                    return "––" // ""
                  }
                }
              } catch {
                Debug.log("[ConvertXLSX.toCSV] Error parsing shared strings: \(error.localizedDescription)")
                return nil
              }
              return nil
            }
            let csvRow = rowData.joined(separator: ",")
            csvData += csvRow + "\n"
          }
        }
      }
      
      guard let appSupportDirectory = Utility.getApplicationSupportDirectory() else {
        return nil
      }
      
      let randomString = Utility.randomString(length: 5)
      let csvFileName = "spreadsheet_\(randomString).csv"
      let csvFileURL = appSupportDirectory.appendingPathComponent(csvFileName)
      
      try csvData.write(to: csvFileURL, atomically: true, encoding: .utf8)
      
      return csvFileURL
    } catch {
      Debug.log("[ConvertXLSX.toCSV] Error converting XLSX to CSV: \(error.localizedDescription)")
      return nil
    }
  }
  
}
