
//
//  FileTemplates.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

/// An enumeration of different file templates.
enum FileTemplates: String, CaseIterable {
  
  /// A case for a generic data file template.
  case generic = "Generic Data"
  /// A case for an Excel spreadsheet file template.
  case excelSpreadsheet = "Excel Spreadsheet"
  /// A case for an App Store Connect Sales file template.
  case appStoreConnectSales = "App Store Connect Sales"
  
  /// Returns an array of strings that represent the filter column headers for each case.
  var filterColumnHeaders: [String] {
    switch self {
    case .generic: return [""]
    case .excelSpreadsheet: return [""]
    case .appStoreConnectSales: return AppStoreConnectSalesColumnHeaders.simplified
    }
  }
  
  /// Returns an array of strings that represent all the raw values of the enumeration cases.
  static var all: [String] {
    return FileTemplates.allCases.map { $0.rawValue }
  }
}
