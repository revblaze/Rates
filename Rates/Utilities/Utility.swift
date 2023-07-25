//
//  Utility.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

/// A structure with helpful utility functions.
struct Utility {
  /// Writes the given data to a file with the specified file name in the user's document directory.
  ///
  /// - Parameters:
  ///   - data: The data to be written to the file. It should be of type `String`.
  ///   - fileName: The name of the file to be created or overwritten with the data. It should be a `String`.
  /// - Throws: An error if there is an issue with writing the data to the file.
  /// - Returns: The URL of the created file in the user's document directory.
  static func writeDataToFile(data: String, fileName: String) throws -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    try data.write(to: fileURL, atomically: true, encoding: .utf8)
    return fileURL
  }
  
  /// Generates a random string of the specified length using alphanumeric characters.
  ///
  /// - Parameter length: The length of the random string to be generated. It should be an `Int`.
  /// - Returns: A random string of the specified length.
  static func randomString(length: Int) -> String {
    let letters = Constants.alphaNumericString
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
  /// Returns the URL of the Application Support directory for the current application.
  ///
  /// This function retrieves the URL of the Application Support directory specific to the current application.
  /// It first gets the general Application Support directory URL, then appends the bundle identifier of the current application to it.
  /// If the directory does not exist, it is created.
  ///
  /// - Returns: The URL of the Application Support directory for the current application, or `nil` if an error occurs during the retrieval or creation of the directory.
  static func getApplicationSupportDirectory() -> URL? {
    let fileManager = FileManager.default
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      return nil
    }
    let appSupportFolderPath = appSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
    do {
      try fileManager.createDirectory(atPath: appSupportFolderPath.path, withIntermediateDirectories: true, attributes: nil)
      return appSupportFolderPath
    } catch {
      Debug.log("[Utility] Error creating Application Support directory: \(error)")
      return nil
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
      Debug.log("[Utility] Successfully removed temporary file at: \(tempFilePath)")
    } catch let error as NSError {
      Debug.log("[Utility] Error: Unable to remove temporary file at \(tempFilePath).\nDescription: \(error.localizedDescription)")
    }
  }
  
  /// Clears the Application Support directory by removing all of its contents.
  ///
  /// This function retrieves the URL of the Application Support directory and removes all of its contents.
  /// If the directory does not exist, or if there is an error during the deletion, an error message is printed.
  ///
  /// - Returns: A boolean value that indicates whether the operation was successful. If the operation was successful, it returns `true`; otherwise, it returns `false`.
  static func clearApplicationSupportDirectory() -> Bool {
    guard let appSupportURL = getApplicationSupportDirectory() else {
      Debug.log("[Utility] Error: Unable to retrieve Application Support directory URL")
      return false
    }
    
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(at: appSupportURL, includingPropertiesForKeys: nil, options: [])
      for filePath in filePaths {
        try fileManager.removeItem(at: filePath)
      }
    } catch {
      Debug.log("[Utility] Error: Unable to clear Application Support directory: \(error)")
      return false
    }
    
    return true
  }
  
  /// Clears the Documents directory by removing all of its contents.
  ///
  /// This function retrieves the URL of the Documents directory and removes all of its contents.
  /// If the directory does not exist, or if there is an error during the deletion, an error message is printed.
  ///
  /// - Returns: A boolean value that indicates whether the operation was successful. If the operation was successful, it returns `true`; otherwise, it returns `false`.
  static func clearApplicationDocumentsDirectory() -> Bool {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    guard let documentsDirectory = paths.first else {
      Debug.log("[Utility] Error: Unable to retrieve Documents directory path")
      return false
    }
    
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
      for filePath in filePaths {
        let fileURL = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(filePath)
        try fileManager.removeItem(at: fileURL)
      }
    } catch {
      Debug.log("[Utility] Error: Unable to clear Documents directory: \(error)")
      return false
    }
    
    return true
  }
  
  /// Searches for a specified file in the documents directory.
  ///
  /// - Parameter fileName: The name of the file to search for.
  /// - Returns: The URL of the found file, or `nil` if the search failed.
  static func searchDocumentsDirectory(forFileName fileName: String) -> URL? {
    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Failed to get document directory URL")
      return nil
    }
    
    // Perform recursive search in the documents directory
    if let fileUrl = searchFile(named: fileName, in: documentDirectoryURL) {
      return fileUrl
    } else {
      Debug.log("[searchDocumentsDirectory] File not found")
      return nil
    }
  }
  
  /// Searches for a file with a specified name in a given directory.
  ///
  /// - Parameters:
  ///   - fileName: The name of the file to search for.
  ///   - directoryURL: The URL of the directory to search in.
  /// - Returns: The URL of the found file, or `nil` if the file was not found.
  static func searchFile(named fileName: String, in directoryURL: URL) -> URL? {
    // Get the contents of the directory
    let fileManager = FileManager.default
    let contents = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
    
    for url in contents ?? [] {
      if url.hasDirectoryPath {
        // Recursive call for subdirectories
        if let foundURL = searchFile(named: fileName, in: url) {
          return foundURL
        }
      } else if url.lastPathComponent == fileName {
        // File found
        return url
      }
    }
    
    // File not found
    return nil
  }
  
}
