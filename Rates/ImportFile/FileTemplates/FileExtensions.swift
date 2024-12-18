//
//  FileExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// An enumeration of different file extensions.
enum FileExtensions: String, CaseIterable {
  
  /// A case for a CSV (Comma Separated Values) file extension.
  case csv
  /// A case for a TSV (Tab Separated Values) file extension.
  case tsv
  /// A case for a TXT (Plain Text) file extension.
  case txt
  /// A case for an XLSX (Excel Spreadsheet) file extension.
  case xlsx
  
  /// Returns an array of strings that represent all the raw values of the enumeration cases.
  static var all: [String] {
    return FileExtensions.allCases.map { $0.rawValue }
  }
  
  /// Returns the full format name of each file extension.
  var fullFormatName: String {
    switch self {
    case .csv: return "Comma Separated Values"
    case .tsv: return "Tab Separated Values"
    case .txt: return "Plain Text"
    case .xlsx: return "Excel Spreadsheet"
    }
  }
  
  var stringWithPeriod: String {
    switch self {
    case .csv: return ".csv"
    case .tsv: return ".tsv"
    case .txt: return ".txt"
    case .xlsx: return ".xlsx"
    }
  }
  
  var canBeExportedWithFormat: [FileExtensions] {
    switch self {
    case .csv: return [.csv]
    case .tsv: return [.tsv]
    case .txt: return [.csv, .tsv]
    case .xlsx: return [.xlsx]
    }
  }
  
  var headerDetectionMethod: DetectHeaderRow {
    switch self {
    case .csv: return .modeNumberOfEntries
    case .tsv: return .modeNumberOfEntries
    case .txt: return .modeNumberOfEntries
    case .xlsx: return .largestNumberOfEntries //.modeNumberOfEntries
    }
  }
  
}

/// An extension to the `URL` structure that adds a `hasFileExtension()` method for checking the file extension of a URL.
extension URL {
  /// Checks the file extension of the URL and returns the corresponding `FileExtensions` case, or `nil` if the file extension is not recognized.
  func hasFileExtension() -> FileExtensions? {
    let fileExtension = self.pathExtension.lowercased()
    
    for case let fileExtensionCase in FileExtensions.allCases {
      if fileExtension == fileExtensionCase.rawValue {
        return fileExtensionCase
      }
    }
    
    return nil
  }
}
