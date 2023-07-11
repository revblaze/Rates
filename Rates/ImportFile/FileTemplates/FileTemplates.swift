//
//  FileTemplates.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

enum FileTemplates: String, CaseIterable {
  
  case generic = "Generic Data"
  case excelSpreadsheet = "Excel Spreadsheet"
  case appStoreConnectSales = "App Store Connect Sales"
  
  var filterColumnHeaders: [String] {
    switch self {
    case .generic: return [""]
    case .excelSpreadsheet: return [""]
    case .appStoreConnectSales: return AppStoreConnectSalesColumnHeaders.simplified
    }
  }
  
  static var all: [String] {
    return FileTemplates.allCases.map { $0.rawValue }
  }
}

