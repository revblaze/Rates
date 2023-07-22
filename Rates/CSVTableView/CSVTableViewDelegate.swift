//
//  CSVTableViewDelegate.swift
//  Rates
//
//  Created by Justin Bush on 7/15/23.
//

import Cocoa

/// Extension of the `CSVTableView` class to conform to the `NSTableViewDelegate` and `NSTableViewDataSource` protocols.
extension CSVTableView: NSTableViewDelegate, NSTableViewDataSource {
  
  /// Returns the number of rows in the table view.
  ///
  /// - Parameter tableView: The table view.
  /// - Returns: The number of rows in the table view.
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tableData.count - 1 // Exclude the header row
  }
  
  /// Returns the view that is associated with a specified row and table column.
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - tableColumn: The table column.
  ///   - row: The row.
  /// - Returns: The view that is associated with `row` and `tableColumn`.
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "csvCell")
    var cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTextFieldCellView
    
    if cellView == nil {
      cellView = NSTextFieldCellView(frame: NSRect.zero)
      cellView?.identifier = cellIdentifier
      cellView?.isBezeled = false
      cellView?.isEditable = false
      cellView?.drawsBackground = false
      cellView?.cell = CenteredTextFieldCell()
    }
    
    let rowIndex = row + 1
    if rowIndex >= 0 && rowIndex < tableData.count {
      let rowData = tableData[rowIndex]
      let columnIndex = tableView.column(withIdentifier: tableColumn!.identifier)
      if columnIndex >= 0 && columnIndex < rowData.count {
        var cellValue = rowData[columnIndex]
        
        // If roundToTwoDecimalPlaces is true, and the cell value can be converted to a Double,
        // round the cell value to two decimal places for display.
        if roundToTwoDecimalPlaces, let doubleValue = Double(cellValue) {
          cellValue = String(format: "%.2f", doubleValue)
        }
        
        cellView?.stringValue = cellValue
      } else {
        cellView?.stringValue = ""
      }
    } else {
      Debug.log("[tableView] Index out of range: row = \(row), tableData count = \(tableData.count)")
      cellView?.stringValue = ""
    }
    
    return cellView
  }
  
  
  
  // MARK: - Custom Header Row
  /// Returns the header row of the currently selected row of the table view.
  ///
  /// If no row is selected in the table view, this method will present an NSAlert to the user instructing them to select a row.
  ///
  /// - Returns: The header row of the currently selected row of the table view, or `nil` if no row is selected.
  func getCurrentlySelectedRow() -> [String]? {
    // Check if a row is selected in the table view.
    let selectedRow = tableView.selectedRow
    if selectedRow >= 0 {
      // Return the header row for the selected row.
      return tableData[selectedRow+1]
    } else {
      // If no row is selected, present an NSAlert to the user.
      let alert = NSAlert()
      alert.messageText = "No Header Row Selected"
      alert.informativeText = "Please select a row that you'd like to set as the header row and try again."
      alert.alertStyle = .warning
      alert.runModal()
      return nil
    }
  }
  
  /// Updates the table columns based on the currently selected header row in the table view.
  ///
  /// This method uses the `getCurrentlySelectedRow()` method to acquire the selected header row. If no row is selected, this method will do nothing.
  func manuallySelectHeaderRow() {
    // Acquire the selected header row using the `getCurrentlySelectedRow()` method.
    guard let selectedHeaderRow = getCurrentlySelectedRow() else {
      // If no row is selected, do nothing.
      return
    }
    
    // Call the `updateTableColumns(withHeaderRowDetection:customHeaderRow:)` method, providing the selected header row.
    updateTableColumns(withHeaderRowDetection: .custom, customHeaderRow: selectedHeaderRow)
  }
  
  // MARK: - Column Header Filtering
  /// Filters the table view columns based on the given headers.
  ///
  /// - Parameters:
  ///   - hidden: A Boolean value indicating whether to hide or show the columns.
  ///   - headers: An array of column headers to include or exclude.
  func filterTableColumns(hidden: Bool, forHeaders headers: [String]) {
    for column in tableView.tableColumns {
      if headers.contains(column.headerCell.stringValue) {
        column.isHidden = hidden
      } else {
        column.isHidden = !hidden
      }
    }
    determineSuggestedHeadersForConversion()
    updateAppForHiddenColumns()
  }
  
  
  // MARK: - Hide/Unhide Columns
  /// Hides the columns that were previously hidden by the filterTableColumns method.
  func rehideColumns() {
    for column in tableView.tableColumns {
      if hiddenColumnHeaders.contains(column.headerCell.stringValue) {
        column.isHidden = true
      }
    }
    updateAppForHiddenColumns()
  }
  
  // TODO: Potentially keep empty columns hidden based on sharedFormattingOptions.hideEmpty
  /// Unhides all columns in the table view.
  func unhideColumns() {
    tableView.tableColumns.forEach { column in
      column.isHidden = false
      column.width = CGFloat(100) // Set a default width if header cell size isn't sufficient
    }
    
    resizeTableViewColumnsToFit()  // Resize columns after unhiding them
    updateAppForUnhiddenColumns()
  }
  
  func updateAppForHiddenColumns() {
    sharedFormattingOptions.hideIrrelevantColumns = true
    viewController?.updateHiddenTableViewColumnsToolbarButton(toBeActive: true)
    
    hiddenColumnHeaders.removeAll()
    for column in tableView.tableColumns {
      if column.isHidden {
        hiddenColumnHeaders.append(column.headerCell.stringValue)
      }
    }
  }
  
  func updateAppForUnhiddenColumns() {
    sharedFormattingOptions.hideIrrelevantColumns = false
    viewController?.updateHiddenTableViewColumnsToolbarButton(toBeActive: false)
  }
  
  /// Returns the table data for the visible columns, excluding leading and trailing empty rows.
  ///
  /// - Returns: The table data for the visible columns, excluding leading and trailing empty rows.
  func getTableDataForVisibleColumns() -> [[String]] {
    // Get the indices of the visible columns
    let visibleColumnIndices = tableView.tableColumns.enumerated()
      .filter { !$1.isHidden }
      .map { $0.offset }
    
    // Filter the table data based on the visible column indices
    var visibleTableData = tableData.map { rowData in
      visibleColumnIndices.compactMap { index in
        index < rowData.count ? rowData[index] : nil
      }
    }
    
    // Remove leading empty rows
    while let firstRow = visibleTableData.first, firstRow.allSatisfy({ $0.isEmpty }) {
      visibleTableData.removeFirst()
    }
    
    // Remove trailing empty rows
    while let lastRow = visibleTableData.last, lastRow.allSatisfy({ $0.isEmpty }) {
      visibleTableData.removeLast()
    }
    
    return visibleTableData
  }
  
}
