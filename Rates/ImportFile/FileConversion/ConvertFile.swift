//
//  ConvertFile.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

struct ConvertFile {
  
  static func toCSV(fileUrl: URL) -> URL? {
    switch fileUrl.hasFileExtension() {
    
    case .csv:
      return fileUrl
    
    case .tsv:
      if let csvFileUrl = ConvertTSV.toCSV(fileURL: fileUrl) {
        return csvFileUrl
      }
      
    case .txt:
      // TODO: Dedicated TXT to CSV handler?
      if let csvFileUrl = ConvertTSV.toCSV(fileURL: fileUrl) {
        return csvFileUrl
      }
      
    case .xlsx:
      if let csvFileUrl = ConvertXLSX.toCSV(fileURL: fileUrl) {
        return csvFileUrl
      }
      
    case .none:
      break
    }
    Debug.log("[ConvertFile.toCSV] No recognizable extension found for file: \(fileUrl)")
    return nil
  }
  
}
