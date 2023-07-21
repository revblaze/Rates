//
//  ViewController+ExportTable.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import Cocoa
import xlsxwriter

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
    // Get the Application Support directory path
    guard let appSupportPath = applicationSupportDirectory()?.path else {
      print("Error: Unable to get the Application Support directory.")
      return nil
    }
    
    print(appSupportPath)
    
    // Create the full path for the temporary XLSX file
    let tempFilePath = (appSupportPath as NSString).appendingPathComponent(fileName).appending(FileExtensions.xlsx.stringWithPeriod)
    
    // Create a new workbook
    let wb = Workbook(name: tempFilePath)
    defer { wb.close() }
    
    // Add a worksheet
    let ws = wb.addWorksheet()
    
    // Add a format
    let format = wb.addFormat()
    
    // Set the bold property for the format
    format.bold()
    
    // Write the data from the table to the XLSX file
    for (rowIndex, rowData) in tableData.enumerated() {
      for (colIndex, cellData) in rowData.enumerated() {
        // If header row
        if rowIndex == 0 {
          // Bold header row
          ws.write(.string(cellData), [rowIndex, colIndex], format: format)
        } else {
          ws.write(.string(cellData), [rowIndex, colIndex])
        }
      }
    }
    
    // Create the NSSavePanel to prompt the user for the file save location
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = fileName
    savePanel.allowedFileTypes = ["xlsx"]
    
    // Display the NSSavePanel and wait for the user's action
    guard savePanel.runModal() == .OK, let url = savePanel.url else {
      // User canceled the save operation or an error occurred
      print("Error: Failed to get the URL for saving the XLSX file.")
      return nil
    }
    
    // Move the XLSX file from the temporary directory to the user-selected location
    do {
      let fileManager = FileManager.default
      try fileManager.moveItem(atPath: tempFilePath, toPath: url.path)
      return url
    } catch let error as NSError {
      print("Error: Unable to save the XLSX file at the specified location.")
      print("Description: \(error.localizedDescription)")
      
      // Show an error alert to the user
      let alert = NSAlert()
      alert.messageText = "Error: Unable to save the XLSX file."
      alert.informativeText = error.localizedDescription
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .critical
      alert.runModal()
      
      return nil
    }
  }
  
  func applicationSupportDirectory() -> URL? {
    let fileManager = FileManager.default
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      return nil
    }
    let appSupportFolderPath = appSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
    do {
      try fileManager.createDirectory(atPath: appSupportFolderPath.path, withIntermediateDirectories: true, attributes: nil)
      return appSupportFolderPath
    } catch {
      print("Error creating Application Support directory: \(error)")
      return nil
    }
  }
  
}



