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
  /// The headers of the columns that are currently hidden.
  var hiddenColumnHeaders: [String] = []
  
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
    
    // Insurance: If tableView is filling with data, make sure FileDropBox is hidden.
    viewController?.hideFileDropBox()
  }
  
  /// Updates the table columns based on the header row of the `tableData`.
  ///
  /// - Parameter withHeaderRowDetection: The mode of detecting the header row in the CSV data.
  func updateTableColumns(withHeaderRowDetection: DetectHeaderRow = .modeNumberOfEntries, customHeaderRow: [String] = [""]) {
    tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
    
    Debug.log("[updateTableColumns] withHeadeRowDetection: \(withHeaderRowDetection)")
    
    var headerRow: [String]? = nil
    
    switch withHeaderRowDetection {
    case .firstRow:
      headerRow = getFirstRowHeaders(from: tableData)
    case .modeNumberOfEntries:
      headerRow = findModeEntryHeaderRow(tableData: tableData)
    case .largestNumberOfEntries:
      headerRow = findLargestNumberEntryHeaderRow(tableData: tableData)
    case .custom:
      headerRow = customHeaderRow
    }
    
    // Make the first row visible by adding an empty row in its place.
    if withHeaderRowDetection != .firstRow {
      tableData.insert([String](repeating: "", count: headerRow?.count ?? 0), at: 0)
    }
    
    guard let foundHeaderRow = headerRow else {
      return
    }
    
    // Update selectedHeaderRowIndex with the index of the header row
    selectedHeaderRowIndex = getSelectedHeaderRowIndex(in: tableData, using: foundHeaderRow, minimumMatchingHeaderItems: 2)
    
    //Debug.log("[updateTableColumns] foundHeaderRow: \(foundHeaderRow)\nselectedHeaderRowIndex: \(selectedHeaderRowIndex)")
    //Debug.log("tableData[selectedHeaderRowIndex]: \(tableData[selectedHeaderRowIndex])")
    
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
    
    tableView.selectRowIndexes(IndexSet(integer: selectedHeaderRowIndex), byExtendingSelection: false)
    //Debug.log("=== TableData ===\n\(tableData)")
    
    // Check to see if data contains a date outside of currently archived Exchange Rate Data.
    checkTableForDateOutsideOfExchangeRateDataRange()
  }
  
  /// Finds the index of the header row in the table data.
  ///
  /// This function compares each row in the table data with the provided header row.
  /// It removes all empty entries from the rows before comparing them.
  /// If a row in the table data has at least `minimumMatchingHeaderItems` items in common with the header row, that row is considered to be the header row.
  ///
  /// - Parameters:
  ///   - tableData: The table data as a two-dimensional array of strings.
  ///   - foundHeaderRow: The detected header row as an array of strings.
  ///   - minimumMatchingHeaderItems: The minimum number of items a row must have in common with the header row to be considered the header row. Defaults to 2.
  ///
  /// - Returns: The index of the header row in the table data. If no suitable header row is found, it returns 0.
  func getSelectedHeaderRowIndex(in tableData: [[String]], using foundHeaderRow: [String], minimumMatchingHeaderItems: Int = 2) -> Int {
    return tableData.firstIndex(where: { row in
      let cleanedRow = row.filter { !$0.isEmpty }
      let cleanedHeaderRow = foundHeaderRow.filter { !$0.isEmpty }
      let commonItems = Set(cleanedRow).intersection(Set(cleanedHeaderRow))
      return commonItems.count >= minimumMatchingHeaderItems
    }) ?? 0
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
      column.width = maxWidth + Constants.tableViewCellWidthPadding
    }
  }
  
  
  
  
  
  // MARK: - Guess Suggested Headers
  //
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
  
  
  
  // MARK: - Currency Conversion
  //
  //
  /// Performs a currency conversion to the specified currency using the given headers.
  ///
  /// - Parameters:
  ///   - toCurrency: The currency code to convert to.
  ///   - usingHeaders: An array of headers used to locate the necessary data.
  ///
  /// - Important:
  ///   - The function assumes the table data is stored in `tableData`.
  ///   - The function creates a new column in the table for the converted amounts.
  ///   - If `headers[2]` is empty or nil, the function calls `splitCurrencyCodesIntoSeparateColumn(amountColumnHeader: headers[1])` and sets `headers[2]` to the return value.
  ///   - If `toCurrency` is not USD, a second column will be created for the converted amounts from USD to the specified currency.
  ///   - The function relies on `Query` class for currency conversion, `Debug` class for logging, and `Utility` class for processing currency codes.
  ///   - Make sure to reload the table data after calling this function.
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
  
  /// Splits the currency codes into a separate column in the table.
  ///
  /// - Parameters:
  ///   - columnHeader: The header row text for a column.
  ///
  /// - Returns: The header text of the newly created column.
  ///
  /// - Important:
  ///   - The function assumes the table data is stored in `tableData`.
  ///   - The function creates a new column in the table for the currency codes.
  ///   - The function relies on `Utility` class for processing the currency codes.
  ///   - Make sure to reload the table data after calling this function.
  func splitCurrencyCodesIntoSeparateColumn(amountColumnHeader columnHeader: String) -> String {
    guard let columnIndex = tableView.tableColumns.firstIndex(where: { $0.title == columnHeader }) else {
      Debug.log("[splitCurrencyCodesIntoSeparateColumn] Unable to find column")
      return ""
    }
    
    // Add a new column to the table
    let currencyCodeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "CurrencyCodeColumn"))
    currencyCodeColumn.title = "From Currency"
    tableView.addTableColumn(currencyCodeColumn)
    let currencyCodeColumnIndex = tableView.tableColumns.count - 1
    
    Debug.log("selectedHeaderRowIndex: \(selectedHeaderRowIndex), currencyCodeColumnIndex: \(currencyCodeColumnIndex)")
    
    // Iterate over the table data and append currency codes alongside their data
    for i in 0..<tableData.count {
      if i == selectedHeaderRowIndex {
        // Create space in the header row for the new column
        tableData[i].insert(currencyCodeColumn.title, at: currencyCodeColumnIndex)
      } else if i > selectedHeaderRowIndex && columnIndex < tableData[i].count {
        var cell = tableData[i][columnIndex]
        let currencyCode = Utility.extractCurrencyCode(&cell, usingCurrencyCodes: sharedHeaders.availableCurrencyCodeHeaders)
        tableData[i][columnIndex] = cell
        tableData[i].insert(currencyCode, at: currencyCodeColumnIndex)
      } else {
        tableData[i].insert("", at: currencyCodeColumnIndex)
      }
    }
    
    tableView.reloadData()
    return currencyCodeColumn.title
  }

  
  /// Creates a new column in the table with converted amounts to USD using the given header information.
  ///
  /// - Parameters:
  ///   - headers: An array of headers used to locate the necessary data. It should contain at least three elements representing the headers for dates, amounts, and currencies, respectively.
  ///
  /// - Important:
  ///   - The function assumes the table data is stored in `tableData`.
  ///   - The function creates a new column in the table titled "To USD" to hold the converted amounts.
  ///   - If any of the required headers (dates, amounts, currencies) cannot be found in the table, the function logs an error using `Debug.log` and returns without performing any conversions.
  ///   - The function uses the `Utility` class to process the amount strings and the `Query` class to perform currency conversion.
  ///   - Make sure to reload the table data after calling this function.
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
    
    // Add a new column to the table
    let usdColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToUsdColumn"))
    usdColumn.title = "To USD"
    tableView.addTableColumn(usdColumn)
    
    let usdColumnIndex = tableView.tableColumns.count - 1
    
    for i in 0..<tableData.count {
      while tableData[i].count < tableView.tableColumns.count - 1 {
        tableData[i].append(Constants.outsideOfTableDataRangePlaceholder)
      }
      
      if i == selectedHeaderRowIndex {
        tableData[i].insert(usdColumn.title, at: usdColumnIndex)
      } else if i > selectedHeaderRowIndex {
        let row = tableData[i]
        if row.count <= max(datesIndex, amountsIndex, currenciesIndex) {
          tableData[i].insert(Constants.outsideOfTableDataRangePlaceholder, at: usdColumnIndex)
          continue
        }
        let date = row[datesIndex]
        var amountString = row[amountsIndex]
        amountString = Utility.removeAlphaAndParseAmount(amountString) ?? amountString
        let currencyCode = row[currenciesIndex]
        
        if let usdValue = Query.valueInUsd(currencyCode: currencyCode, amountOfCurrency: amountString, onDate: date) {
          tableData[i].insert(String(usdValue), at: usdColumnIndex)
        } else {
          Debug.log("[createUsdColumnWithConvertedAmounts] Unable to convert value for row \(i)")
          tableData[i].insert(Constants.unableToConvertValuePlaceholder, at: usdColumnIndex)
        }
      } else {
        tableData[i].insert(Constants.outsideOfTableDataRangePlaceholder, at: usdColumnIndex)
      }
    }
    
    tableView.reloadData()
  }
  
  /// Creates a new column in the table with converted amounts from USD to a specified currency using the given header information.
  ///
  /// - Parameters:
  ///   - code: The currency code of the target currency to convert amounts to.
  ///   - datesHeader: The header text for the column containing dates in the table.
  ///
  /// - Important:
  ///   - The function assumes the table data is stored in `tableData`.
  ///   - The function creates a new column in the table titled "To [code]" to hold the converted amounts.
  ///   - If the header specified by `datesHeader` or the "To USD" column (required for conversion) cannot be found in the table, the function logs an error using `Debug.log` and returns without performing any conversions.
  ///   - The function uses the `Query` class to perform currency conversion.
  ///   - Make sure to reload the table data after calling this function.
  func createSecondColumnWithConvertedAmounts(toCurrency code: String, usingDatesHeader datesHeader: String) {
    guard let datesIndex = tableView.tableColumns.firstIndex(where: { $0.title == datesHeader }),
          let usdColumnIndex = tableView.tableColumns.firstIndex(where: { $0.identifier.rawValue == "ToUsdColumn" }) else {
      Debug.log("[createSecondColumnWithConvertedAmounts] Unable to find one or more columns")
      return
    }
    
    // Add a new column to the table
    newCurrencyColumnCount += 1
    let newCurrencyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "ToNewCurrency-\(newCurrencyColumnCount)"))
    newCurrencyColumn.title = "To \(code)"
    tableView.addTableColumn(newCurrencyColumn)
    
    let newCurrencyColumnIndex = tableView.tableColumns.count - 1
    
    for i in 0..<tableData.count {
      while tableData[i].count < tableView.tableColumns.count - 1 {
        tableData[i].append(Constants.outsideOfTableDataRangePlaceholder)
      }
      
      if i == selectedHeaderRowIndex {
        tableData[i].insert(newCurrencyColumn.title, at: newCurrencyColumnIndex)
      } else if i > selectedHeaderRowIndex {
        let row = tableData[i]
        if row.count <= max(datesIndex, usdColumnIndex) {
          tableData[i].insert(Constants.outsideOfTableDataRangePlaceholder, at: newCurrencyColumnIndex)
          continue
        }
        let date = row[datesIndex]
        let usdAmountString = row[usdColumnIndex]
        
        if let newCurrencyValue = Query.valueInNewCurrency(fromUsdAmount: usdAmountString, toCurrencyCode: code, onDate: date) {
          tableData[i].insert(String(newCurrencyValue), at: newCurrencyColumnIndex)
        } else {
          Debug.log("[createSecondColumnWithConvertedAmounts] Unable to convert value for row \(i)")
          tableData[i].insert(Constants.unableToConvertValuePlaceholder, at: newCurrencyColumnIndex)
        }
      } else {
        tableData[i].insert(Constants.outsideOfTableDataRangePlaceholder, at: newCurrencyColumnIndex)
      }
    }
    
    tableView.reloadData()
  }

  
  
  
  
  // MARK: - Shared Formatting Options
  //
  //
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
    
    updateAppForHiddenColumns()
  }
  
  // MARK: - Rounding 2 Decimal Places
  /// Rounds all cell values in the table view to two decimal places for display.
  ///
  /// The actual cell values remain the same.
  func enableRoundToTwoDecimalPlaces() {
    roundToTwoDecimalPlaces = true
    tableView.reloadData()
    resizeTableViewColumnsToFit()
    sharedFormattingOptions.roundToTwoDecimalPlaces = true
    viewController?.updateRoundToTwoDecimalPlacesToolbarButton(toBeActive: true)
    
  }
  
  /// Shows all cell values in the table view as they are, without rounding to two decimal places.
  func disableRoundToTwoDecimalPlaces() {
    roundToTwoDecimalPlaces = false
    tableView.reloadData()
    resizeTableViewColumnsToFit()
    sharedFormattingOptions.roundToTwoDecimalPlaces = false
    viewController?.updateRoundToTwoDecimalPlacesToolbarButton(toBeActive: false)
  }
  
  
  /// This function checks each cell of the table data to see if it contains a date that is outside of the exchange rate data range.
  ///
  /// - Parameter tableData: The table data to be checked.
  ///
  /// - Important:
  ///   - This function runs asynchronously.
  ///   - It first defines an Int variable, `cutOffYearInt`, which is equal to `Int(viewController?.sharedSettings.cutOffYear)`.
  ///   - It then asynchronously iterates through each cell of the table data.
  ///   - If the cell contains a number, it attempts to convert that cell string to a `Date` object using `returnDateFromDateString(cellString)`.
  ///   - If `returnDateFromDateString` returns a valid `Date`, it then converts that `Date` to a year string and then to an `Int`.
  ///   - If the year as an `Int` is less than `cutOffYearInt`, it keeps track of the smallest year found.
  ///   - Once all cells have been checked, it returns the smallest year found to the closure.
  func didDetectDateOutsideOfExchangeRateDataRange(tableData: [[String]], completion: @escaping (String) -> Void) {
    guard let cutOffYearString = viewController?.sharedSettings.cutOffYear, let cutOffYearInt = Int(cutOffYearString) else { return }
    
    DispatchQueue.global().async {
      var smallestYearInt = cutOffYearInt
      for row in tableData {
        for cell in row {
          if let date = Utility.returnDateFromDateString(cell),
             let yearString = Utility.returnYearStringFromDate(date),
             let yearInt = Int(yearString),
             yearInt < smallestYearInt {
            smallestYearInt = yearInt
            Debug.log("New smallest year found: \(yearString). Original cell value: \(cell)")
          }
        }
      }
      completion(String(smallestYearInt))
    }
  }
  
  /// This function checks if there is a date that is outside of the exchange rate data range in the table data.
  ///
  /// If such a date is found, it shows an alert to the user.
  func checkTableForDateOutsideOfExchangeRateDataRange() {
    didDetectDateOutsideOfExchangeRateDataRange(tableData: tableData) { yearString in
      guard let cutOffYearString = self.viewController?.sharedSettings.cutOffYear, let cutOffYearInt = Int(cutOffYearString), let newCutOffYearInt = Int(yearString) else { return }
      
      if newCutOffYearInt < cutOffYearInt {
        Debug.log("[checkTableForDateOutsideOfExchangeRateDataRange] Found date outside of exchange rate data range: \(yearString)")
        self.presentUserWithDateOutOfRangeAlert(forYear: yearString)
      }
    }
  }
  
  func presentUserWithDateOutOfRangeAlert(forYear yearString: String) {
    guard let cutOffYearString = self.viewController?.sharedSettings.cutOffYear else { return }
    
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Download Missing Rates"
      alert.informativeText = "The exchange rate data you currently have downloaded includes the years:\n\(cutOffYearString) – Present Day\n\nHowever, we've found at least one entry in your file that has the year \(yearString).\n\nWould you like to update your exchange rate data to include the following years:\n\(yearString) – Present Day"
//      alert.messageText = "Download Rates for \(yearString)+"
//      alert.informativeText = "The exchange rate data you currently have downloaded starts from \(cutOffYearString).\n\nHowever, we've found at least one entry in your file that has the year \(yearString).\n\nWould you like to update your exchange rate data to include the years \(yearString) and beyond?"
      alert.alertStyle = .informational
      alert.addButton(withTitle: "Download")
      alert.addButton(withTitle: "Not Now")
      
      let modalResult = alert.runModal()

      switch modalResult {
      case .alertFirstButtonReturn:
        Debug.log("[CSVTableView] User clicked 'Download Update'")
        // Add code to download update
        self.viewController?.downloadDataForNewCutOffYearSettings(newCutOffYear: yearString)
        
      case .alertSecondButtonReturn:
        Debug.log("[CSVTableView] User clicked 'Not Now' for downloading exchange rate data.")
        // Add code to handle 'Not Now' action
        self.presentUserWithSettingsNoticeAlert()
      default:
        break
      }
    }
  }
  
  func presentUserWithSettingsNoticeAlert() {
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Available in Settings"
      alert.informativeText = "You can always download additional years of exchange rate data in Settings."
      alert.alertStyle = .informational
      alert.addButton(withTitle: "OK")
      
      let modalResult = alert.runModal()
      
      switch modalResult {
      case .alertFirstButtonReturn:
        Debug.log("User clicked 'OK'")
        // Add code to download update
      default:
        break
      }
    }
  }
  
  
}
