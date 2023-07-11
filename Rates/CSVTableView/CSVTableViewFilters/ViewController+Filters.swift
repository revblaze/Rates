//
//  ViewController+Filters.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

extension ViewController {
  
  // MARK: CSVTableView Filters
  func revertTableViewChanges() {
    csvTableView.unhideColumns()
  }
  func filterAppStoreConnectSales() {
    csvTableView.filterAppStoreConnectSales()
  }
  
}
