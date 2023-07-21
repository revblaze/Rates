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
    let csvFileURL = documentsDirectory.appendingPathComponent(fileName)
    try data.write(to: csvFileURL, atomically: true, encoding: .utf8)
    return csvFileURL
  }
  
  /// Generates a random string of the specified length using alphanumeric characters.
  ///
  /// - Parameter length: The length of the random string to be generated. It should be an `Int`.
  /// - Returns: A random string of the specified length.
  static func randomString(length: Int) -> String {
    let letters = Constants.alphaNumericString
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
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
      print("Error creating Application Support directory: \(error)")
      return nil
    }
  }
  
}
