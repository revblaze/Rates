//
//  ViewController+Filters.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// Extension of the `ViewController` class to add additional methods for handling CSV table view filters.
extension ViewController {
  
  /// Manually selects the header row of the currently selected CSVTableView row.
  func selectCustomHeaderForTableView() {
    csvTableView.manuallySelectHeaderRow()
  }
  
  /// Reverts the changes to the CSV table view.
  func revertTableViewChanges() {
    csvTableView.unhideColumns()
  }
  
}
