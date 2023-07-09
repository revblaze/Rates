//
//  CSVTableView.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

class CSVTableView: NSView, NSTableViewDataSource, NSTableViewDelegate {
  
  private var tableView: NSTableView!
  private var data: [[String]] = [] // Array to store CSV data
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    setupTableView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupTableView()
  }
  
  private func setupTableView() {
    tableView = NSTableView(frame: bounds)
    tableView.dataSource = self
    tableView.delegate = self
    
    addSubview(tableView)
    
    // Add table columns based on the number of columns in the CSV
    if let columnCount = data.first?.count {
      for columnIndex in 0..<columnCount {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ColumnIdentifier\(columnIndex)"))
        column.width = bounds.width / CGFloat(columnCount)
        tableView.addTableColumn(column)
      }
    }
    
    tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    guard let columnIndex = tableView.tableColumns.firstIndex(of: tableColumn!) else {
      return nil
    }
    
    let rowData = data[row]
    
    if columnIndex < rowData.count {
      return rowData[columnIndex]
    }
    
    return nil
  }
  
  func updateCSVData(with url: URL) {
    do {
      let csvData = try String(contentsOf: url, encoding: .utf8)
      data = csvData.csvRows() // Parse CSV data into array of rows
      
      // Remove existing table columns
      tableView.tableColumns.forEach { column in
        tableView.removeTableColumn(column)
      }
      
      // Add new table columns based on the number of columns in the updated CSV data
      if let columnCount = data.first?.count {
        for columnIndex in 0..<columnCount {
          let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ColumnIdentifier\(columnIndex)"))
          column.width = bounds.width / CGFloat(columnCount)
          tableView.addTableColumn(column)
        }
      }
      
      tableView.reloadData()
    } catch {
      print("Error reading CSV file: \(error.localizedDescription)")
    }
  }
  
  override func layout() {
    super.layout()
    tableView.frame = bounds
    resizeTableColumnsToFitData()
  }
  
  private func resizeTableColumnsToFitData() {
    tableView.tableColumns.forEach { column in
      let columnIndex = tableView.tableColumns.firstIndex(of: column)!
      
      var maxWidth: CGFloat = 0
      for rowIndex in 0..<data.count {
        let rowData = data[rowIndex]
        if columnIndex < rowData.count {
          let cellValue = rowData[columnIndex]
          let cellSize = cellValue.size(withAttributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
          maxWidth = max(maxWidth, cellSize.width)
        }
      }
      
      let padding: CGFloat = 10
      column.width = maxWidth + padding
    }
  }
  
  func tableViewColumnDidResize(_ notification: Notification) {
    resizeTableColumnsToFitData()
  }
}

extension String {
  // Extension to parse CSV rows into a 2D array
  func csvRows() -> [[String]] {
    var rows: [[String]] = []
    let lines = self.components(separatedBy: .newlines)
    
    for line in lines {
      let fields = line.components(separatedBy: ",")
      rows.append(fields)
    }
    
    return rows
  }
}
