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
  /// SharedFormattingOptions instance for communicating with SwiftUI view.
  var sharedFormattingOptions: SharedFormattingOptions
  /// Referenc to ViewController delegate.
  weak var viewController: ViewController?
  /// Number of new currency columns for identification.
  var newCurrencyColumnCount = 0
  /// Determines whether to round cell values to two decimal places for display.
  var roundToTwoDecimalPlaces = false
  /// The index of the currently selected header row.
  var selectedHeaderRowIndex: Int = 0
  
  /// Initializes the view with a given frame rectangle.
  ///
  /// - Parameters:
  ///   - frameRect: The frame rectangle for the view.
  ///   - sharedHeaders: SharedHeaders instance for communicating with SwiftUI view.
  init(frame frameRect: NSRect, sharedHeaders: SharedHeaders, sharedFormattingOptions: SharedFormattingOptions) {
    self.sharedHeaders = sharedHeaders
    self.sharedFormattingOptions = sharedFormattingOptions
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
    
    // Update selectedHeaderRowIndex with the index of the header row
    selectedHeaderRowIndex = tableData.firstIndex(where: { $0 == foundHeaderRow }) ?? 0
    
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
  
  /// Replaces suggestedHeaders with column headers for detected data types, if applicable.
  func determineSuggestedHeadersForConversion() {
    sharedHeaders.suggestedHeaders.removeAll()
    let datesColumn = guessDatesColumn()
    let amountsColumn = guessAmountsColumn()
    let currenciesColumn = guessCurrenciesColumn()
    sharedHeaders.suggestedHeaders.append(datesColumn)
    sharedHeaders.suggestedHeaders.append(amountsColumn)
    sharedHeaders.suggestedHeaders.append(currenciesColumn)
    Debug.log("[determineSuggestedHeadersForConversion] update headers: \(sharedHeaders.suggestedHeaders)")
  }
  
  /// Finds a column that contains dates.
  ///
  /// - Returns: The header of a column that contains dates, or `nil` if no such column is found.
  func guessDatesColumn() -> String? {
    for rowIndex in (selectedHeaderRowIndex + 1)..<tableData.count {
      let row = tableData[rowIndex]
      for column in tableView.tableColumns where !column.isHidden {
        let columnIndex = tableView.column(withIdentifier: column.identifier)
        guard columnIndex < row.count else { continue }
        let cell = row[columnIndex]
        if Utility.isDateString(cell) {
          return column.title
        }
      }
    }
    return nil
  }
  
  /// Finds a column that contains numbers with two decimal places.
  ///
  /// Before determining if a cell contains a number with two decimal places,
  /// it removes any characters that are not a number, period, or minus ("-") from the cell string.
  ///
  /// - Returns: The header of a column that contains numbers with two decimal places, or `nil` if no such column is found.
  func guessAmountsColumn() -> String? {
    for rowIndex in (selectedHeaderRowIndex + 1)..<tableData.count {
      let row = tableData[rowIndex]
      for column in tableView.tableColumns where !column.isHidden {
        let columnIndex = tableView.column(withIdentifier: column.identifier)
        guard columnIndex < row.count else { continue }
        let cell = row[columnIndex]
        // Remove any characters that are not a number, period, or minus ("-") from the cell string
        let cleanedCell = Utility.removeAlphaAndParseAmount(cell) ?? cell
        if Utility.isNumberWithTwoDecimalsString(cleanedCell) {
          return column.title
        }
      }
    }
    return nil
  }
  
  /// Finds a column that contains currency codes.
  ///
  /// - Returns: The header of a column that contains currency codes, or `nil` if no such column is found.
  func guessCurrenciesColumn() -> String? {
    for rowIndex in (selectedHeaderRowIndex + 1)..<tableData.count {
      let row = tableData[rowIndex]
      for column in tableView.tableColumns where !column.isHidden {
        let columnIndex = tableView.column(withIdentifier: column.identifier)
        guard columnIndex < row.count else { continue }
        let cell = row[columnIndex]
        if Utility.isCurrencyCode(cell) {
          return column.title
        }
      }
    }
    return nil
  }
  
  /**
   Performs a currency conversion to the specified currency using the given headers.
   
   - Parameters:
   - toCurrency: The currency code to convert to.
   - usingHeaders: An array of headers used to locate the necessary data.
   
   - Important:
   - The function assumes the table data is stored in `tableData`.
   - The function creates a new column in the table for the converted amounts.
   - If `headers[2]` is empty or nil, the function calls `splitCurrencyCodesIntoSeparateColumn(amountColumnHeader: headers[1])` and sets `headers[2]` to the return value.
   - If `toCurrency` is not USD, a second column will be created for the converted amounts from USD to the specified currency.
   - The function relies on `Query` class for currency conversion, `Debug` class for logging, and `Utility` class for processing currency codes.
   - Make sure to reload the table data after calling this function.
   */
  func performConversion(toCurrency code: String, usingHeaders headers: [String]) {
    var headers = headers
    // If the currency codes have already been split from the amount column, do not re-split them.
    if headers[2].isEmpty, tableView.tableColumns.first(where: { $0.identifier.rawValue == "CurrencyCodeColumn" })?.isHidden != false {
      headers[2] = splitCurrencyCodesIntoSeparateColumn(amountColumnHeader: headers[1])
    }
    
    Debug.log("[performConversion] toCurrency: \(code), usingHeaders: \(headers)")
    
    // If the USD column already exists and is visible, do not re-calculate the USD column.
    if tableView.tableColumns.first(where: { $0.identifier.rawValue == "ToUsdColumn" })?.isHidden != false {
      createUsdColumnWithConvertedAmounts(usingHeaders: headers)
    }
    
    if code != "USD" {
      let datesHeader = headers[0]
      createSecondColumnWithConvertedAmounts(toCurrency: code, usingDatesHeader: datesHeader)
    }
    
    checkAndApplyFormattingOptions(withHeaders: headers)
  }
  
  /**
   Splits the currency codes into a separate column in the table.
   
   - Parameters:
   - columnHeader: The header row text for a column.
   
   - Returns: The header text of the newly created column.
   
   - Important:
   - The function assumes the table data is stored in `tableData`.
   - The function creates a new column in the table for the currency codes.
   - The function relies on `Utility` class for processing the currency codes.
   - Make sure to reload the table data after calling this function.
   */
  func splitCurrencyCodesIntoSeparateColumn(amountColumnHeader columnHeader: String) -> String {
    guard let columnIndex = tableView.tableColumns.firstIndex(where: { $0.title == columnHeader }) else {
      Debug.log("[splitCurrencyCodesIntoSeparateColumn] Unable to find column")
      return ""
    }
    
    // Initialize the new column with empty cells
    var currencyCodes = Array(repeating: "", count: tableData.count)
    
    for i in (selectedHeaderRowIndex + 1)..<tableData.count {
      var cell = tableData[i][columnIndex]
      
      let currencyCode = Utility.extractCurrencyCode(&cell, usingCurrencyCodes: sharedHeaders.availableCurrencyCodeHeaders)
      currencyCodes[i] = currencyCode
      
      tableData[i][columnIndex] = cell  // Update the cell value
    }
    
    // Add a new column to the table
    let currencyCodeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "CurrencyCodeColumn"))
    currencyCodeColumn.title = "From Currency"
    
    tableView.addTableColumn(currencyCodeColumn)
    
    tableData[selectedHeaderRowIndex].append(currencyCodeColumn.title)
    // Add the currency codes to the table data
    for (i, currencyCode) in currencyCodes.enumerated() {
      tableData[i].append(currencyCode)
    }
    
    tableView.reloadData()
    
    return currencyCodeColumn.title
  }
  
  /// Creates a new column in the table with amounts converted to USD from their original currency.
  /// It uses the headers provided to find the date, amount and currency code in each row.
  /// If a cell is empty or the conversion to USD fails, a default value of 0.0 is used.
  /// After the conversion, the new column is added to the table and the table data is updated.
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
    
    // Initialize the new column with empty cells
    var usdValues = Array(repeating: "", count: tableData.count)
    
    for i in (selectedHeaderRowIndex + 1)..<tableData.count {
      let row = tableData[i]
      
      // If any of the indices are out of bounds, skip this row
      if row.count <= max(datesIndex, amountsIndex, currenciesIndex) {
        Debug.log("[createUsdColumnWithConvertedAmounts] Row \(i) does not contain all required columns")
        continue
      }
      
      let date = row[datesIndex]
      var amountString = row[amountsIndex]
      
      // Remove any characters that are not a number, period, or minus ("-")
      amountString = Utility.removeAlphaAndParseAmount(amountString) ?? amountString
      
      let currencyCode = row[currenciesIndex]
      
      if let usdValue = Query.valueInUsd(currencyCode: currencyCode, amountOfCurrency: amountString, onDate: date) {
        // Replace the cell at the processed row index with the calculated value
        usdValues[i] = String(usdValue)
      } else {
        Debug.log("[createUsdColumnWithConvertedAmounts] Unable to convert value for row \(i)")
        usdValues[i] = "0.0"  // Or some other default value
      }
    }
    
    // Add a new column to the table
    let usdColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToUsdColumn"))
    usdColumn.title = "To USD"
    
    tableView.addTableColumn(usdColumn)
    

    // Add the USD values to the table data
    tableData[0].append(usdColumn.title)  // Add column header to the first row of tableData
    
    for (i, usdValue) in usdValues.enumerated() {
      tableData[i].append(usdValue)
    }
    
    tableView.reloadData()
  }
  
  /// Creates a new column in the table with amounts converted from USD to the specified currency.
  /// It uses the datesHeader to find the date in each row and assumes the amount in USD is in a column with identifier "ToUsdColumn".
  /// If a cell is empty or the conversion fails, a default value of 0.0 is used.
  /// After the conversion, the new column is added to the table and the table data is updated.
  func createSecondColumnWithConvertedAmounts(toCurrency code: String, usingDatesHeader datesHeader: String) {
    guard let datesIndex = tableView.tableColumns.firstIndex(where: { $0.title == datesHeader }),
          let usdColumnIndex = tableView.tableColumns.firstIndex(where: { $0.identifier.rawValue == "ToUsdColumn" }) else {
      Debug.log("[createSecondColumnWithConvertedAmounts] Unable to find one or more columns")
      return
    }
    
    // Initialize the new column with empty cells
    var newCurrencyValues = Array(repeating: "", count: tableData.count)
    
    for i in (selectedHeaderRowIndex + 1)..<tableData.count {
      let row = tableData[i]
      // Check if indices are within bounds
      guard row.count > datesIndex, row.count > usdColumnIndex else {
        continue
      }
      let date = row[datesIndex]
      let usdAmountString = row[usdColumnIndex]
      
      if let newCurrencyValue = Query.valueInNewCurrency(fromUsdAmount: usdAmountString, toCurrencyCode: code, onDate: date) {
        // Replace the cell at the processed row index with the calculated value
        newCurrencyValues[i] = String(newCurrencyValue)
      } else {
        Debug.log("[createSecondColumnWithConvertedAmounts] Unable to convert value for row \(i)")
        newCurrencyValues[i] = "0.0"  // Or some other default value
      }
    }
    
    // Add a new column to the table
    newCurrencyColumnCount += 1
    let newCurrencyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToNewCurrency-\(newCurrencyColumnCount)"))
    newCurrencyColumn.title = "To \(code)"
    
    tableView.addTableColumn(newCurrencyColumn)
    
    // Add the new currency values to the table data
    tableData[0].append(usdColumn.title)  // Add column header to the first row of tableData
    //tableData[0].append(newCurrencyColumn.title)  // Add column header to the first row of tableData
    for (i, newCurrencyValue) in newCurrencyValues.enumerated() {
      tableData[i].append(newCurrencyValue)
    }
    
    tableView.reloadData()
  }
  
  
  // MARK: - Shared Formatting Options
  
  
  /// Checks to see if the user has applied any SharedFormattingOptions and triggers the code if applicable.
  func checkAndApplyFormattingOptions(withHeaders headers: [String]) {
    if sharedFormattingOptions.roundToTwoDecimalPlaces {
      enableRoundToTwoDecimalPlaces()
    } else {
      disableRoundToTwoDecimalPlaces()
    }
    
    hideEmptyColumns(userSelectedHeaders: headers)
    hideIrrelevantColumns(userSelectedHeaders: headers)
  }
  
  /// This function removes all of the columns from the CSVTableView whose values consist of empty cells, spaces, tabs,
  /// or a combination of the three, unless one of these conditions is met:
  /// - The header cell text is equal to any string within the input parameter 'headers'.
  /// - The NSTableColumn identifier NSUserInterfaceItemIdentifier rawValue is equal to one of these Strings ["CurrencyCodeColumn", "ToUsdColumn"].
  /// - The NSTableColumn identifier NSUserInterfaceItemIdentifier rawValue is prefixed with "ToNewCurrency-".
  /// The function only runs if the `sharedFormattingOptions.removeEmptyColumns` property is true.
  ///
  /// - Parameter headers: An array of headers that should not be removed.
  func hideEmptyColumns(userSelectedHeaders headers: [String]) {
    // Check if the sharedFormattingOptions.hideEmptyColumns property is true.
    guard sharedFormattingOptions.hideEmptyColumns else {
      return
    }
    
    // Loop through all the columns in the table.
    for column in tableView.tableColumns {
      let identifier = column.identifier.rawValue
      let headerText = column.headerCell.stringValue
      
      // If the column header or identifier matches the specified conditions, skip the column.
      guard !Utility.shouldSkipColumn(headerText: headerText, identifier: identifier, headers: headers) else {
        continue
      }
      
      let columnIndex = tableView.column(withIdentifier: column.identifier)
      
      // If all the cells in the column (excluding the header) are empty, hide the column.
      if Utility.isColumnEmpty(data: tableData, columnIndex: columnIndex) {
        column.isHidden = true
      }
    }
  }
  
  /// This function hides all of the columns from the CSVTableView unless one of these conditions is met:
  /// - The header cell text is equal to any string within the input parameter 'headers'.
  /// - The NSTableColumn identifier NSUserInterfaceItemIdentifier rawValue is equal to one of these Strings ["CurrencyCodeColumn", "ToUsdColumn"].
  /// - The NSTableColumn identifier NSUserInterfaceItemIdentifier rawValue is prefixed with "ToNewCurrency-".
  /// The function only runs if the `sharedFormattingOptions.hideIrrelevantColumns` property is true.
  ///
  /// - Parameter headers: An array of headers that should not be hidden.
  func hideIrrelevantColumns(userSelectedHeaders headers: [String]) {
    // Check if the sharedFormattingOptions.hideIrrelevantColumns property is true.
    guard sharedFormattingOptions.hideIrrelevantColumns else {
      return
    }
    
    // Loop through all the columns in the table.
    for column in tableView.tableColumns {
      let identifier = column.identifier.rawValue
      let headerText = column.headerCell.stringValue
      
      // If the column header or identifier does not match the specified conditions, hide the column.
      if !Utility.shouldSkipColumn(headerText: headerText, identifier: identifier, headers: headers) {
        column.isHidden = true
      }
    }
  }
  
  // MARK: - Rounding 2 Decimal Places
  /// Rounds all cell values in the table view to two decimal places for display.
  ///
  /// The actual cell values remain the same.
  func enableRoundToTwoDecimalPlaces() {
    roundToTwoDecimalPlaces = true
    tableView.reloadData()
    sharedFormattingOptions.roundToTwoDecimalPlaces = true
    viewController?.updateRoundToTwoDecimalPlacesToolbarButton(toBeActive: true)
    
  }
  
  /// Shows all cell values in the table view as they are, without rounding to two decimal places.
  func disableRoundToTwoDecimalPlaces() {
    roundToTwoDecimalPlaces = false
    tableView.reloadData()
    sharedFormattingOptions.roundToTwoDecimalPlaces = false
    viewController?.updateRoundToTwoDecimalPlacesToolbarButton(toBeActive: false)
  }
  
  
}



/// A custom text field cell view with a custom intrinsic content size.
class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
