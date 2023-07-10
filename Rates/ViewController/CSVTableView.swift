//
//  CSVTableView.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

class CSVTableView: NSView {
  
  private var tableView: NSTableView!
  private var tableData: [[String]] = []
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupTableView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupTableView()
  }
  
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
  
  func updateCSVData(with url: URL) {
    if let csvString = try? String(contentsOf: url, encoding: .utf8) {
      let rows = csvString.components(separatedBy: .newlines)
      tableData = rows
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: ",") }
      
      updateTableColumns()
      tableView.reloadData()
    }
  }
  
  private func updateTableColumns() {
    tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
    
    if let headerRow = tableData.first {
      for (index, header) in headerRow.enumerated() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column\(index)"))
        column.title = header
        tableView.addTableColumn(column)
      }
    }
  }
  
  func unhideColumns() {
    tableView.tableColumns.forEach { column in
      column.isHidden = false
    }
  }
  
  // MARK: App Store Connect
  func filterAppStoreConnectSales() {
    filterAppStoreConnectSalesColumns(tableView: tableView)
  }
  
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

extension CSVTableView: NSTableViewDelegate, NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tableData.count - 1 // Exclude the header row
  }
  
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

class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
