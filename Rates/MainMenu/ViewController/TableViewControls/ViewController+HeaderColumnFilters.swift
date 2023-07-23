//
//  ViewController+HeaderColumnFilters.swift
//  Rates
//
//  Created by Justin Bush on 7/18/23.
//

import Foundation

extension ViewController {
  
  /// Filters the table view column headers based on the specified filter type.
  ///
  /// - Parameters:
  ///   - columnHeaders: An array of column headers to apply the filter to.
  ///   - withFilterType: The filter type to determine whether to show or hide the columns.
  ///
  /// This method is called to filter the column headers of a table view based on the specified filter type.
  ///
  /// The `columnHeaders` parameter represents the array of column headers to be filtered, and the `withFilterType` parameter indicates whether to show or hide the columns.
  ///
  /// The filter type is determined by the `FilterTableViewInclusionExclusion` enum, which provides two options:
  /// - `.filterTableViewToOnlyShowColumnsWithHeaders`: Indicates that only the columns with the specified headers should be shown in the table view.
  /// - `.filterTableViewToOnlyHideColumnsWithHeaders`: Indicates that the columns with the specified headers should be hidden in the table view.
  ///
  /// When the `withFilterType` is `.filterTableViewToOnlyShowColumnsWithHeaders`, this method calls the `filterTableViewToOnlyShowColumnsWithHeaders` function of the `CSVTableView` class, passing the `columnHeaders` array as a parameter. This function will filter the table view to only display the columns with the specified headers.
  ///
  /// Conversely, when the `withFilterType` is `.filterTableViewToOnlyHideColumnsWithHeaders`, this method calls the `filterTableViewToOnlyHideColumnsWithHeaders` function of the `CSVTableView` class, passing the `columnHeaders` array as a parameter. This function will filter the table view to hide the columns with the specified headers.
  ///
  /// Example usage:
  /// ```swift
  /// let columnHeaders = ["Header1", "Header2", "Header3"]
  /// let filterType = FilterTableViewInclusionExclusion.filterTableViewToOnlyShowColumnsWithHeaders
  /// filterTableViewColumnHeaders(columnHeaders, withFilterType: filterType)
  /// Note: To reset the table view headers to their default state and display all columns, use the resetTableViewHeadersToDefault function of the CSVTableView class.
  ///
  func filterTableViewColumnHeaders(_ columnHeaders: [String], withFilterType: FilterTableViewInclusionExclusion) {
    if withFilterType == .filterTableViewToOnlyShowColumnsWithHeaders {
      csvTableView.filterTableViewToOnlyShowColumnsWithHeaders(columnHeaders)
    } else {
      csvTableView.filterTableViewToOnlyHideColumnsWithHeaders(columnHeaders)
    }
  }
  
}
