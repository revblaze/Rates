//
//  ExportTable.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import Cocoa
import CoreXLSX

struct ExportTable {
  
  /// A structure representing the export table.
  struct ExportTable {
    
    /// Creates a file with the given name, file extension, data format, and table data.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - fileExtension: The file extension.
    ///   - dataFormat: The data format.
    ///   - tableData: The table data.
    /// - Returns: The URL of the created file.
    static func asFile(withName fileName: String, fileExtension: FileExtensions, dataFormat: FileExtensions, tableData: [[String]]) -> URL? {
      switch fileExtension {
      case .csv:
        return toCsvDataStructure(fileName: fileName, tableData: tableData)
      case .tsv:
        return toTsvDataStructure(fileName: fileName, tableData: tableData)
      case .xlsx:
        return toXlsxDataStructure(fileName: fileName, tableData: tableData)
      case .txt:
        switch dataFormat {
        case .csv:
          return toCsvDataStructure(fileName: fileName, tableData: tableData)
        case .tsv:
          return toTsvDataStructure(fileName: fileName, tableData: tableData)
        default:
          return nil
        }
      }
    }
    
    /// Converts the table data to CSV data structure and saves the file.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - tableData: The table data.
    /// - Returns: The URL of the created CSV file.
    static func toCsvDataStructure(fileName: String, tableData: [[String]]) -> URL? {
      // Implement CSV conversion here.
      return nil
    }
    
    /// Converts the table data to TSV data structure and saves the file.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - tableData: The table data.
    /// - Returns: The URL of the created TSV file.
    static func toTsvDataStructure(fileName: String, tableData: [[String]]) -> URL? {
      // Implement TSV conversion here.
      return nil
    }
    
    /// Converts the table data to XLSX data structure and saves the file.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - tableData: The table data.
    /// - Returns: The URL of the created XLSX file.
    static func toXlsxDataStructure(fileName: String, tableData: [[String]]) -> URL? {
      // Implement XLSX conversion here.
      return nil
    }
    
  }
  
}
