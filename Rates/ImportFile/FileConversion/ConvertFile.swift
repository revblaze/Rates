
//
//  ConvertFile.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

/// A structure with a static method for converting a file to CSV format.
struct ConvertFile {
  
  /// Converts a file to CSV format based on its file extension.
  ///
  /// - Parameter fileUrl: The URL of the file.
  /// - Returns: The URL of the CSV file, or `nil` if the file extension is not recognized or the conversion fails.
  static func toCSV(fileUrl: URL) -> URL? {
    switch fileUrl.hasFileExtension() {
      
    case .csv:
      return fileUrl
      
    case .tsv:
      if let csvFileUrl = ConvertTSV.toCSV(fileUrl: fileUrl) {
        return csvFileUrl
      }
      
    case .txt:
      // TODO: Dedicated TXT to CSV handler?
      if let csvFileUrl = ConvertTSV.toCSV(fileUrl: fileUrl) {
        return csvFileUrl
      }
      
    case .xlsx:
      if let csvFileUrl = ConvertXLSX.toCSV(fileUrl: fileUrl) {
        return csvFileUrl
      }
      
    case .none:
      break
    }
    Debug.log("[ConvertFile.toCSV] No recognizable extension found for file: \(fileUrl)")
    return nil
  }
  
}
