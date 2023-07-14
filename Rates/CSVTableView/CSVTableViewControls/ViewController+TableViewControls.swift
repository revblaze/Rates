//
//  ViewController+TableViewControls.swift
//  Rates
//
//  Created by Justin Bush on 7/14/23.
//

import Foundation

/// Extension of the `ViewController` class to add additional methods for handling custom CSVTableView controls.
extension ViewController {
  
  /// Manually selects the header row of the currently selected CSVTableView row.
  func selectCustomHeaderForTableView() {
    csvTableView.manuallySelectHeaderRow()
  }
  
}
