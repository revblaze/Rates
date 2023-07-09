//
//  CSVFileTemplates.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

enum CSVFileTemplates {
  
  case generic
  case appStoreConnectSales
  
  var filterColumnHeaders: [String] {
    switch self {
    case .generic: return [""]
    case .appStoreConnectSales: return AppStoreConnectSalesColumnHeaders.simplified
    }
  }
  
}

class CSVFileTemplateParsing {
  
  
  
}
