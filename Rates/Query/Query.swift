//
//  Query.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import Foundation

struct Query {
  
  static let sharedHeaders = SharedHeaders()
  
  static func sqliteUrl() -> URL? {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    
    if let fileUrl = documentsDirectory?.appendingPathComponent(Constants.sqliteFileName), fileManager.fileExists(atPath: fileUrl.path) {
      return fileUrl
    }
    
    return nil
  }
  
  
  
  
}
