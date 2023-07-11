//
//  StructureFile.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

struct StructureFile {
  
  static func forTableView(csvFileUrl: URL) -> URL? {
    
    Debug.log("[StructureFile] csvFileUrl: \(csvFileUrl)")
    
    if FileTemplateParsing.containsAppStoreConnectHeaders(fileUrl: csvFileUrl) {
      
      
      
    }
    
    return csvFileUrl
    
  }
  
}
