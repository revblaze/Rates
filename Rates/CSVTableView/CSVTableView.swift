//
//  CSVTableView.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa
import Combine

class SharedHeaders: ObservableObject {
  @Published var availableHeaders: [String] = []
  @Published var suggestedHeaders: [String] = []
}

/// A custom view for displaying CSV data in a table view.
class CSVTableView: NSView {
  
  /// The table view for displaying CSV data.
  var tableView: NSTableView!
  /// The data to be displayed in the table view.
  var tableData: [[String]] = []
  /// SharedHeaders instance for communicating with SwiftUI view.
  var sharedHeaders: SharedHeaders
  
  /// Initializes the view with a given frame rectangle.
  ///
  /// - Parameters:
  ///   - frameRect: The frame rectangle for the view.
  ///   - sharedHeaders: SharedHeaders instance for communicating with SwiftUI view.
  init(frame frameRect: NSRect, sharedHeaders: SharedHeaders) {
    self.sharedHeaders = sharedHeaders
    super.init(frame: frameRect)
    setupTableView()
  }
  /// Initializes the view from data in a given unarchiver.
  ///
  /// - Parameter aDecoder: An unarchiver object.
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupTableView() {
    tableView = NSTableView(frame: bounds)
    tableView.autoresizingMask = [.height]
    tableView.columnAutoresizingStyle = .noColumnAutoresizing
    tableView.usesAlternatingRowBackgroundColors = true
    
    let scrollView = NSScrollView(frame: bounds)
    scrollView.autoresizingMask = [.width, .height]
    scrollView.documentView = tableView
    addSubview(scrollView)
    
    tableView.allowsColumnResizing = true  // Enable column resizing
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
      resizeTableViewColumnsToFit()
    }
  }
  
  /// Updates the table columns based on the header row of the `tableData`.
  ///
  /// - Parameter withHeaderRowDetection: The mode of detecting the header row in the CSV data.
  func updateTableColumns(withHeaderRowDetection: DetectHeaderRow = .modeNumberOfEntries, customHeaderRow: [String] = [""]) {
    tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
    
    var headerRow: [String]? = nil
    
    switch withHeaderRowDetection {
    case .modeNumberOfEntries:
      headerRow = CSVTableView.findModeEntryHeaderRow(tableData: tableData)
    case .largestNumberOfEntries:
      headerRow = CSVTableView.findLargestNumberEntryHeaderRow(tableData: tableData)
    case .custom:
      headerRow = customHeaderRow
    }
    
    guard let foundHeaderRow = headerRow else {
      return
    }
    
    for (index, header) in foundHeaderRow.enumerated() {
      let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column\(index)"))
      column.title = header
      column.maxWidth = CGFloat.greatestFiniteMagnitude  // Allow the column to grow as wide as needed
      tableView.addTableColumn(column)
      column.sizeToFit()  // Resize the column to fit its content
    }
    
    // Update shared headers
    sharedHeaders.availableHeaders = foundHeaderRow
    determineSuggestedHeadersForConversion()
  }
  
  /// Resizes all columns in the table view to fit the widest content of their cells.
  ///
  /// This method iterates over all columns in the table view, and for each column,
  /// it calculates the width of the content of all cells, finds the maximum width,
  /// and sets the width of the column to this maximum value.
  func resizeTableViewColumnsToFit() {
    for column in tableView.tableColumns {
      let columnIndex = tableView.column(withIdentifier: column.identifier)
      var maxWidth: CGFloat = 0
      for row in 0..<tableView.numberOfRows {
        if let cellView = tableView.view(atColumn: columnIndex, row: row, makeIfNecessary: true) as? NSTextFieldCellView {
          let cell = NSTextFieldCell()
          cell.stringValue = cellView.stringValue
          let cellSize = cell.cellSize(forBounds: NSRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
          maxWidth = max(maxWidth, cellSize.width)
        }
      }
      column.width = maxWidth
    }
  }
  
  /// Unhides all columns in the table view.
  func unhideColumns() {
    tableView.tableColumns.forEach { column in
      column.isHidden = false
      column.width = CGFloat(100) // Set a default width if header cell size isn't sufficient
    }
    
    resizeTableViewColumnsToFit()  // Resize columns after unhiding them
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
  
  
  func determineSuggestedHeadersForConversion() {
    sharedHeaders.suggestedHeaders.removeAll()
    let datesColumn = guessDatesColumn()
    let amountsColumn = guessAmountsColumn()
    let currenciesColumn = guessCurrenciesColumn()
    sharedHeaders.suggestedHeaders.append(datesColumn)
    sharedHeaders.suggestedHeaders.append(amountsColumn)
    sharedHeaders.suggestedHeaders.append(currenciesColumn)
    Debug.log("[determineSuggestedHeadersForConversion] update headers: \(datesColumn), \(amountsColumn), \(currenciesColumn)")
  }
  
  
  /// Checks if the given string can be converted to a date.
  ///
  /// - Parameter dateString: The string to check.
  /// - Returns: A Boolean value indicating whether the string can be converted to a date.
  private func isDateString(_ dateString: String) -> Bool {
    let dateFormats = ["yyyy-MM-dd", "yyyy-dd-MM", "dd-MM-yyyy", "MM-dd-yyyy", "yyyy/MM/dd", "yyyy/dd/MM", "dd/MM/yyyy", "MM/dd/yyyy", "MMMM dd, yyyy", "dd MMMM, yyyy"]
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    for format in dateFormats {
      formatter.dateFormat = format
      if formatter.date(from: dateString) != nil {
        return true
      }
    }
    
    return false
  }
  
  /// Checks if the given string can be converted to a number with two decimal places.
  ///
  /// - Parameter numberString: The string to check.
  /// - Returns: A Boolean value indicating whether the string can be converted to a number with two decimal places.
  private func isNumberWithTwoDecimalsString(_ numberString: String) -> Bool {
    let components = numberString.components(separatedBy: ".")
    
    if components.count == 2, components[1].count == 2, Double(numberString) != nil {
      return true
    }
    
    return false
  }
  
  /// Checks if the given string is a valid currency code.
  ///
  /// - Parameter currencyString: The string to check.
  /// - Returns: A Boolean value indicating whether the string is a valid currency code.
  private func isCurrencyCode(_ currencyString: String) -> Bool {
    return Locale.commonISOCurrencyCodes.contains(currencyString.uppercased())
  }
  
  /// Finds a column that contains dates.
  ///
  /// - Returns: The header of a column that contains dates, or an empty string if no such column is found.
  func guessDatesColumn() -> String {
      for column in tableView.tableColumns where !column.isHidden {
          let columnIndex = tableView.column(withIdentifier: column.identifier)
          let columnData = tableData.compactMap { $0.indices.contains(columnIndex) ? $0[columnIndex] : nil }
          for cell in columnData.dropFirst() {
              if isDateString(cell) {
                  return column.title
              }
          }
      }
      return ""
  }
  
  /// Finds a column that contains numbers with two decimal places.
  ///
  /// - Returns: The header of a column that contains numbers with two decimal places, or an empty string if no such column is found.
  func guessAmountsColumn() -> String {
    for column in tableView.tableColumns where !column.isHidden {
      let columnIndex = tableView.column(withIdentifier: column.identifier)
      let columnData = tableData.compactMap { $0.indices.contains(columnIndex) ? $0[columnIndex] : nil }
      if columnData.dropFirst().allSatisfy(isNumberWithTwoDecimalsString) {
        return column.title
      }
    }
    return ""
  }
  
  /// Finds a column that contains currency codes.
  ///
  /// - Returns: The header of a column that contains currency codes, or an empty string if no such column is found.
  func guessCurrenciesColumn() -> String {
    for column in tableView.tableColumns where !column.isHidden {
      let columnIndex = tableView.column(withIdentifier: column.identifier)
      let columnData = tableData.compactMap { $0.indices.contains(columnIndex) ? $0[columnIndex] : nil }
      if columnData.dropFirst().allSatisfy(isCurrencyCode) {
        return column.title
      }
    }
    return ""
  }
  
}



/// A custom text field cell view with a custom intrinsic content size.
class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
