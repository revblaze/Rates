//
//  CSVTableView.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

/// A custom view for displaying CSV data in a table view.
class CSVTableView: NSView {
  
  /// The table view for displaying CSV data.
  private var tableView: NSTableView!
  /// The data to be displayed in the table view.
  private var tableData: [[String]] = []
  
  /// Initializes the view with a given frame rectangle.
  ///
  /// - Parameter frameRect: The frame rectangle for the view.
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupTableView()
  }
  
  /// Initializes the view from data in a given unarchiver.
  ///
  /// - Parameter aDecoder: An unarchiver object.
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupTableView()
  }
  
  /// Sets up the table view.
  private func setupTableView() {
    tableView = NSTableView(frame: bounds)
    tableView.autoresizingMask = [.width, .height]
    
    let scrollView = NSScrollView(frame: bounds)
    scrollView.autoresizingMask = [.width, .height]
    scrollView.documentView = tableView
    addSubview(scrollView)
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  /// Updates the CSV data with the data from a given URL.
  ///
  /// - Parameters:
  ///   - url: The URL of the CSV data.
  ///   - withHeaderRowDetection: The mode of detecting the header row in the CSV data.
  func updateCSVData(with url: URL, withHeaderRowDetection: DetectHeaderRow = .modeNumberOfEntries) {
    if let csvString = try? String(contentsOf: url, encoding: .utf8) {
      let rows = csvString.components(separatedBy: .newlines)
      tableData = rows
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: ",") }
      
      updateTableColumns(withHeaderRowDetection: withHeaderRowDetection)
      tableView.reloadData()
    }
  }
  
  /// Updates the table columns based on the header row of the `tableData`.
  ///
  /// - Parameter withHeaderRowDetection: The mode of detecting the header row in the CSV data.
  private func updateTableColumns(withHeaderRowDetection: DetectHeaderRow = .modeNumberOfEntries) {
    tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
    
    var headerRow: [String]? = nil
    
    switch withHeaderRowDetection {
    case .modeNumberOfEntries:
      headerRow = CSVTableView.findModeEntryHeaderRow(tableData: tableData)
    case .largestNumberOfEntries:
      headerRow = CSVTableView.findLargestNumberEntryHeaderRow(tableData: tableData)
    }
    
    guard let foundHeaderRow = headerRow else {
      return
    }
    
    for (index, header) in foundHeaderRow.enumerated() {
      let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column\(index)"))
      column.title = header
      tableView.addTableColumn(column)
    }
  }
  
  /// Unhides all columns in the table view.
  func unhideColumns() {
    tableView.tableColumns.forEach { column in
      column.isHidden = false
    }
  }
  
  // MARK: App Store Connect
  /// Filters the table view for App Store Connect sales.
  func filterAppStoreConnectSales() {
    filterAppStoreConnectSalesColumns(tableView: tableView)
  }
  
  /// Filters the columns in the table view for App Store Connect sales with given column headers.
  ///
  /// - Parameters:
  ///   - tableView: The table view to filter.
  ///   - withColumns: The column headers for App Store Connect sales. See `AppStoreConnectSalesColumnHeaders.simplified` or `.expanded`.
  func filterAppStoreConnectSalesColumns(tableView: NSTableView, withColumns: [String] = AppStoreConnectSalesColumnHeaders.simplified) {
    let filterStrings = withColumns
    
    let columnsToKeep = tableView.tableColumns.filter { column in
      filterStrings.contains(column.title)
    }
    
    for column in tableView.tableColumns {
      if columnsToKeep.contains(column) {
        column.isHidden = false
      } else {
        column.isHidden = true
      }
    }
  }
}

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
    }
    
    let rowData = tableData[row + 1] // Skip the header row
    let columnIndex = tableView.column(withIdentifier: tableColumn!.identifier)
    if columnIndex < rowData.count {
      cellView?.stringValue = rowData[columnIndex]
    } else {
      cellView?.stringValue = ""
    }
    
    return cellView
  }
  
}

/// A custom text field cell view with a custom intrinsic content size.
class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
