//
//  FileExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

enum FileExtensions: String, CaseIterable {
  
case csv, tsv, txt
  
  static var all: [String] {
    return FileExtensions.allCases.map { $0.rawValue }
  }
  
}

extension URL {
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
