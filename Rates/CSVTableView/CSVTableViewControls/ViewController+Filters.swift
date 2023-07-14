//
//  ViewController+Filters.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// Extension of the `ViewController` class to add additional methods for handling CSV table view filters.
extension ViewController {
  
  /// Reverts the changes to the CSV table view.
  func revertTableViewChanges() {
    csvTableView.unhideColumns()
  }
  
  /// Filters the CSV table view for App Store Connect sales.
  func filterAppStoreConnectSales() {
    csvTableView.filterAppStoreConnectSales()
  }
  
}
