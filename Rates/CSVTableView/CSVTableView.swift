//
//  CSVTableView.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa
import SQLite

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
  
  
  
  
  /// Finds a column that contains dates.
  ///
  /// - Returns: The header of a column that contains dates, or an empty string if no such column is found.
  func guessDatesColumn() -> String {
    for column in tableView.tableColumns where !column.isHidden {
      let columnIndex = tableView.column(withIdentifier: column.identifier)
      let columnData = tableData.compactMap { $0.indices.contains(columnIndex) ? $0[columnIndex] : nil }
      for cell in columnData.dropFirst() {
        if Utility.isDateString(cell) {
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
      for cell in columnData.dropFirst() {
        if Utility.isNumberWithTwoDecimalsString(cell) {
          return column.title
        }
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
      for cell in columnData.dropFirst() {
        if Utility.isCurrencyCode(cell) {
          return column.title
        }
      }
    }
    return ""
  }
  
  func prepareForConversion() {
    
  }
  
  /**
   Performs a currency conversion to the specified currency using the given headers.
   
   - Parameters:
   - toCurrency: The currency code to convert to.
   - usingHeaders: An array of headers used to locate the necessary data.
   
   - Important:
   - The function assumes the table data is stored in `tableData`.
   - The function creates a new column in the table for the converted amounts.
   - If `toCurrency` is not USD, a second column will be created for the converted amounts from USD to the specified currency.
   - The function relies on `Query` class for currency conversion and `Debug` class for logging.
   - Make sure to reload the table data after calling this function.
   */
  func performConversion(toCurrency code: String, usingHeaders headers: [String]) {
    
    // TODO: Clean up $ and other symbols
    // TODO: if headers.count < 3 { separate amount + currency codes into separate arrays }
    
    Debug.log("[performConversion] toCurrency: \(code), usingHeaders: \(headers)")
    //let conversionRate = Query.usdExchangeRate(forCurrency: code, onDate: dates)
    createUsdColumnWithConvertedAmounts(usingHeaders: headers)
    
    if code != "USD" {
      let datesHeader = headers[0]
      createSecondColumnWithConvertedAmounts(toCurrency: code, usingDatesHeader: datesHeader)
    }
  }
  
  /**
   Creates a new column in the table with converted amounts in USD.
   
   - Parameters:
   - usingHeaders: An array of headers used to locate the necessary data.
   
   - Important:
   - The function assumes the table data is stored in `tableData`.
   - The function adds a new column to the table.
   - The function relies on `Query` class for currency conversion and `Debug` class for logging.
   - Make sure to reload the table data after calling this function.
   */
  func createUsdColumnWithConvertedAmounts(usingHeaders headers: [String]) {
    let datesHeader = headers[0]
    let amountsHeader = headers[1]
    let currenciesHeader = headers[2]
    
    guard let datesIndex = tableView.tableColumns.firstIndex(where: { $0.title == datesHeader }),
          let amountsIndex = tableView.tableColumns.firstIndex(where: { $0.title == amountsHeader }),
          let currenciesIndex = tableView.tableColumns.firstIndex(where: { $0.title == currenciesHeader }) else {
      Debug.log("[createUsdColumnWithConvertedAmounts] Unable to find one or more columns")
      return
    }
    
    var usdValues: [Double] = []
    for i in 1..<tableData.count {  // Skip the header row
      let row = tableData[i]
      let date = row[datesIndex]
      let amountString = row[amountsIndex]
      let currencyCode = row[currenciesIndex]
      
      if let usdValue = Query.valueInUsd(currencyCode: currencyCode, amountOfCurrency: amountString, onDate: date) {
        usdValues.append(usdValue)
      } else {
        Debug.log("[createUsdColumnWithConvertedAmounts] Unable to convert value for row \(i)")
        usdValues.append(0.0)  // Or some other default value
      }
    }
    
    // Add a new column to the table
    let usdColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToUsdColumn"))
    usdColumn.title = "To USD"
    
    tableView.addTableColumn(usdColumn)
    
    // Add the USD values to the table data
    for (i, usdValue) in usdValues.enumerated() {
      tableData[i+1].append(String(usdValue))
    }
    
    tableView.reloadData()
  }
  
  /**
   Creates a new column in the table with converted amounts from USD to the specified currency.
   
   - Parameters:
   - code: The currency code to convert to.
   - datesHeader: The header containing the dates for the conversions.
   
   - Important:
   - The function assumes the table data is stored in `tableData`.
   - The function adds a new column to the table.
   - The function relies on `Query` class for currency conversion and `Debug` class for logging.
   - Make sure to reload the table data after calling this function.
   */
  func createSecondColumnWithConvertedAmounts(toCurrency code: String, usingDatesHeader datesHeader: String) {
    
    guard let datesIndex = tableView.tableColumns.firstIndex(where: { $0.title == datesHeader }),
          let usdColumnIndex = tableView.tableColumns.firstIndex(where: { $0.identifier.rawValue == "ToUsdColumn" }) else {
      Debug.log("[createSecondColumnWithConvertedAmounts] Unable to find one or more columns")
      return
    }
    
    var newCurrencyValues: [Double] = []
    for i in 1..<tableData.count {  // Skip the header row
      let row = tableData[i]
      let date = row[datesIndex]
      let usdAmountString = row[usdColumnIndex]
      
      if let newCurrencyValue = Query.valueInNewCurrency(fromUsdAmount: usdAmountString, toCurrencyCode: code, onDate: date) {
        newCurrencyValues.append(newCurrencyValue)
      } else {
        Debug.log("[createSecondColumnWithConvertedAmounts] Unable to convert value for row \(i)")
        newCurrencyValues.append(0.0)  // Or some other default value
      }
    }
    
    // Add a new column to the table
    let newCurrencyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToNewCurrency"))
    newCurrencyColumn.title = "To \(code)"
    
    tableView.addTableColumn(newCurrencyColumn)
    
    // Add the new currency values to the table data
    for (i, newCurrencyValue) in newCurrencyValues.enumerated() {
      tableData[i+1].append(String(newCurrencyValue))
    }
    
    tableView.reloadData()
  }
  
  
}



/// A custom text field cell view with a custom intrinsic content size.
class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
