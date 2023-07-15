//
//  CSV+FilterControls.swift
//  Rates
//
//  Created by Justin Bush on 7/15/23.
//

import Cocoa

extension CSVTableView {
  
  /// Filters the table view to show only columns with headers specified in `columnHeaders`.
  ///
  /// - Parameter columnHeaders: An array of column headers to include in the table view.
  func filterTableViewToOnlyShowColumnsWithHeaders(_ columnHeaders: [String]) {
    filterTableColumns(hidden: false, forHeaders: columnHeaders)
  }
  
  /// Filters the table view to hide columns with headers specified in `columnHeaders`.
  ///
  /// - Parameter columnHeaders: An array of column headers to hide in the table view.
  func filterTableViewToOnlyHideColumnsWithHeaders(_ columnHeaders: [String]) {
    filterTableColumns(hidden: true, forHeaders: columnHeaders)
  }
  
  /// Resets the table view headers to their default state.
  ///
  /// This function unhides all table view columns and resizes them to fit their original widths.
  func resetTableViewHeadersToDefault() {
    unhideColumns()
  }
  
  
}
