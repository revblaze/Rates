
//
//  StructureFile.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

/// A structure with a static method for structuring a file for a table view.
struct StructureFile {
  
  /// Structures a CSV file for a table view.
  ///
  /// - Parameters:
  ///   - csvFileUrl: The URL of the CSV file.
  ///   - withTemplate: The file template.
  /// - Returns: The URL of the structured CSV file.
  static func forTableView(csvFileUrl: URL, withTemplate: FileTemplates) -> URL? {
    
    Debug.log("[StructureFile] csvFileUrl: \(csvFileUrl)")
    
    if FileTemplateParsing.containsAppStoreConnectHeaders(fileUrl: csvFileUrl) {
      
      // TODO: Implement the structuring of the CSV file for a table view if the file contains App Store Connect headers
      
    }
    
    return csvFileUrl
    
  }
  
}
