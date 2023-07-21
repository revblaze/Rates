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
  /// This function writes the provided table data to a temporary file in the Application Support directory,
  /// then prompts the user to save the file at a location of their choice.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - fileExtension: The file extension.
  ///   - dataFormat: The data format.
  ///   - tableData: The table data.
  ///   - completion: A closure that is called when the file is saved, or when an error occurs.
  ///                 The closure takes one argument: an optional URL. If the file is saved
  ///                 successfully, this URL points to the file's location. If an error occurs,
  ///                 the URL is nil.
  func saveTableViewAsFile(withName fileName: String, fileExtension: FileExtensions, dataFormat: FileExtensions, tableData: [[String]], completion: @escaping (URL?) -> Void) {
    switch fileExtension {
    case .csv:
      // Implement CSV conversion here
      completion(nil)
    case .tsv:
      // Implement TSV conversion here
      completion(nil)
    case .xlsx:
      tableToXlsxDataStructure(fileName: fileName, fileExtension: .xlsx, tableData: tableData, completion: completion)
    case .txt:
      switch dataFormat {
      case .csv:
        // Implement CSV conversion here
        completion(nil)
      case .tsv:
        // Implement TSV conversion here
        completion(nil)
      default:
        completion(nil)
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
  /// This function creates a temporary XLSX file in the Application Support directory,
  /// writes the provided table data to this file, then prompts the user to save the file
  /// at a location of their choice.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file.
  ///   - fileExtension: The extension of the file.
  ///   - tableData: The table data.
  ///   - completion: A closure that is called when the file is saved, or when an error occurs.
  ///                 The closure takes one argument: an optional URL. If the file is saved
  ///                 successfully, this URL points to the file's location. If an error occurs,
  ///                 the URL is nil.
  func tableToXlsxDataStructure(fileName: String, fileExtension: FileExtensions, tableData: [[String]], completion: @escaping (URL?) -> Void) {
    // Get the Application Support directory path
    guard let appSupportPath = Utility.getApplicationSupportDirectory()?.path else {
      Debug.log("Error: Unable to get the Application Support directory.")
      return
    }
    
    // Create the full path for the temporary XLSX file
    let tempFilePath = (appSupportPath as NSString).appendingPathComponent(fileName).appending(fileExtension.stringWithPeriod)
    
    // Create a new workbook
    let wb = Workbook(name: tempFilePath)
    let ws = wb.addWorksheet()
    let format = wb.addFormat()
    
    // Set the bold property for the format
    format.bold()
    
    let group = DispatchGroup() // Define a new dispatch group
    group.enter() // Enter the group before starting the write operation
    
    DispatchQueue.global(qos: .background).async {
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
      wb.close()    // Close the workbook to save file
      group.leave() // Leave the group when the write operation is complete
    }
    
    group.notify(queue: .main) {
      // Prompt the user to save the file at a location of their choice
      self.promptUserToSaveFile(tempFilePath: tempFilePath, fileName: fileName, fileExtension: fileExtension, completion: completion)
    }
  }
  
  /// Prompts the user to save the file at a location of their choice.
  ///
  /// This function displays a save panel to the user, then moves the temporary file to
  /// the user-selected location.
  ///
  /// - Parameters:
  ///   - tempFilePath: The path of the temporary file.
  ///   - fileName: The name of the file.
  ///   - fileExtension: The extension of the file.
  ///   - completion: A closure that is called when the file is saved, or when an error occurs.
  ///                 The closure takes one argument: an optional URL. If the file is saved
  ///                 successfully, this URL points to the file's location. If an error occurs,
  ///                 the URL is nil.
  func promptUserToSaveFile(tempFilePath: String, fileName: String, fileExtension: FileExtensions, completion: @escaping (URL?) -> Void) {
    // Create the NSSavePanel to prompt the user for the file save location
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = fileName
    savePanel.allowedFileTypes = [fileExtension.rawValue]
    
    let fullFileName = "\(fileName)\(fileExtension.stringWithPeriod)"
    // Display the NSSavePanel and wait for the user's action
    guard savePanel.runModal() == .OK, let url = savePanel.url else {
      // User canceled the save operation or an error occurred
      Debug.log("Error: Failed to get the URL for saving \(fullFileName)")
      removeTempFileOnFailure(tempFilePath: tempFilePath)
      completion(nil)
      return
    }
    
    // Move the XLSX file from the temporary directory to the user-selected location
    let fileManager = FileManager.default
    do {
      try fileManager.moveItem(atPath: tempFilePath, toPath: url.path)
      completion(url)
    } catch let error as NSError {
      Debug.log("Error: Unable to save \(fullFileName) at the specified location.\nDescription: \(error.localizedDescription)")
      removeTempFileOnFailure(tempFilePath: tempFilePath)
      
      // Show an error alert to the user
      let alert = NSAlert()
      alert.messageText = "Error: Unable to save \(fullFileName)"
      alert.informativeText = error.localizedDescription
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .critical
      alert.runModal()
      
      completion(nil)
    }
  }
  
  /// Removes the temporary file in the event of a failure.
  ///
  /// This function deletes a temporary file from the Application Support directory when
  /// the file fails to be moved to the user-selected location.
  ///
  /// - Parameters:
  ///   - tempFilePath: The path of the temporary file.
  func removeTempFileOnFailure(tempFilePath: String) {
    let fileManager = FileManager.default
    do {
      try fileManager.removeItem(atPath: tempFilePath)
      Debug.log("Successfully removed temporary file at: \(tempFilePath)")
    } catch let error as NSError {
      Debug.log("Error: Unable to remove temporary file at \(tempFilePath).\nDescription: \(error.localizedDescription)")
    }
  }
  
}
