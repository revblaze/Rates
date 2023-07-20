//
//  ViewController+ExportTable.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import Cocoa
import CoreXLSX

extension ViewController {
  
  /// Creates a file with the given name, file extension, data format, and table data.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - fileExtension: The file extension.
  ///   - dataFormat: The data format.
  ///   - tableData: The table data.
  /// - Returns: The URL of the created file.
  func saveTableViewAsFile(withName fileName: String, fileExtension: FileExtensions, dataFormat: FileExtensions, tableData: [[String]]) -> URL? {
    switch fileExtension {
    case .csv:
      return tableToCsvDataStructure(fileName: fileName, tableData: tableData)
    case .tsv:
      return tableToTsvDataStructure(fileName: fileName, tableData: tableData)
    case .xlsx:
      return tableToXlsxDataStructure(fileName: fileName, tableData: tableData)
    case .txt:
      switch dataFormat {
      case .csv:
        return tableToCsvDataStructure(fileName: fileName, tableData: tableData)
      case .tsv:
        return tableToTsvDataStructure(fileName: fileName, tableData: tableData)
      default:
        return nil
      }
    }
  }
  
  /// Converts the table data to CSV data structure and saves the file.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - tableData: The table data.
  /// - Returns: The URL of the created CSV file.
  func tableToCsvDataStructure(fileName: String, tableData: [[String]]) -> URL? {
    // Implement CSV conversion here.
    return nil
  }
  
  /// Converts the table data to TSV data structure and saves the file.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - tableData: The table data.
  /// - Returns: The URL of the created TSV file.
  func tableToTsvDataStructure(fileName: String, tableData: [[String]]) -> URL? {
    // Implement TSV conversion here.
    return nil
  }
  
  /// Converts the table data to XLSX data structure and saves the file.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - tableData: The table data.
  /// - Returns: The URL of the created XLSX file.
  func tableToXlsxDataStructure(fileName: String, tableData: [[String]]) -> URL? {
    // Create a workbook.
    var workbook = Workbook()
    
    // Create a worksheet.
    var worksheet = Worksheet()
    
    // Convert each row in tableData to a row in the worksheet.
    for (rowIndex, row) in tableData.enumerated() {
      var cells: [Cell] = []
      for (columnIndex, column) in row.enumerated() {
        let cellReference = CellReference(column: columnIndex + 1, row: rowIndex + 1)
        let cell = Cell(reference: cellReference, value: column)
        cells.append(cell)
      }
      let worksheetRow = Row(cells: cells, number: UInt(rowIndex + 1))
      worksheet.data?.rows.append(worksheetRow)
    }
    
    // Add the worksheet to the workbook.
    workbook.appendWorksheet(name: "Sheet1", worksheet: worksheet)
    
    // Get the file URL.
    let directory = FileManager.default.temporaryDirectory
    let fileURL = directory.appendingPathComponent(fileName).appendingPathExtension("xlsx")
    
    // Save the workbook to the file.
    do {
      try workbook.save(as: fileURL)
    } catch {
      print("Failed to save workbook: \(error)")
      return nil
    }
    
    // Prompt the user to save the file.
    let savePanel = NSSavePanel()
    savePanel.directoryURL = fileURL
    savePanel.nameFieldStringValue = fileName
    savePanel.allowedFileTypes = ["xlsx"]
    savePanel.begin { (result) in
      if result == NSApplication.ModalResponse.OK {
        do {
          try FileManager.default.moveItem(at: fileURL, to: savePanel.url!)
        } catch {
          print("Failed to move file: \(error)")
        }
      }
    }
    
    return savePanel.url
  }
  
}
