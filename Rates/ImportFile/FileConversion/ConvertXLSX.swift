//
//  ConvertXLSX.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation
import CoreXLSX

struct ConvertXLSX {
  
  static func toCSV(fileURL: URL) -> URL? {
    do {
      guard let file = XLSXFile(filepath: fileURL.path) else {
        fatalError("XLSX file at \(fileURL.path) is corrupted or does not exist")
      }
      
      var csvData = ""
      
      for workbook in try file.parseWorkbooks() {
        for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
          if let worksheetName = name {
            print("This worksheet has a name: \(worksheetName)")
          }
          
          let worksheet = try file.parseWorksheet(at: path)
          for row in worksheet.data?.rows ?? [] {
            let rowData = row.cells.compactMap { cell -> String? in
              if let value = cell.value {
                return "\(value)"
              } else if let formula = cell.formula {
                return "\(formula)"
              } else {
                return nil
              }
            }
            let csvRow = rowData.joined(separator: ",")
            csvData += csvRow + "\n"
          }
        }
      }
      
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let randomString = String((0..<5).map { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
      let csvFileName = "spreadsheet_\(randomString).csv"
      let csvFileURL = documentsDirectory.appendingPathComponent(csvFileName)
      
      try csvData.write(to: csvFileURL, atomically: true, encoding: .utf8)
      
      return csvFileURL
    } catch {
      print("Error converting XLSX to CSV: \(error.localizedDescription)")
      return nil
    }
  }
  
}
