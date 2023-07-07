//
//  ParseCSV.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation
import SwiftCSV
import SQLite

class ParseCSV {
  
  func clean(at fileURL: URL) throws {
    // Read the file contents
    let fileContents = try String(contentsOf: fileURL)
    
    // Split the file contents into individual lines
    var lines = fileContents.components(separatedBy: .newlines)
    
    // Substrings to check for at the beginning of lines
    let substringsToDelete = [
      "\"Frequency\"",
      "\"Reference area\"",
      "\"Collection\"",
      "\"Unit Multiplier\"",
      "\"Decimals\"",
      "\"Availability\"",
      "\"Title\"",
      "\"Time Period\""
    ]
    
    // Iterate through the lines and delete those starting with specified substrings
    lines.removeAll { line in
      substringsToDelete.contains { line.hasPrefix($0) }
    }
    
    // Replace substrings between ":" and "\"" on the line starting with "\"Currency\""
    if let currencyIndex = lines.firstIndex(where: { $0.hasPrefix("\"Currency\"") }) {
      var currencyLine = lines[currencyIndex]
      let components = currencyLine.components(separatedBy: ",")
      let modifiedArray = components.map { element -> String in
          let modifiedElement = element.replacingOccurrences(of: ":.*?\"", with: "\"", options: .regularExpression)
          return modifiedElement
      }
      
      let combinedString = modifiedArray.joined(separator: ",")
      
      currencyLine = combinedString

      // Replace the original line with the updated line
      lines[currencyIndex] = currencyLine
    }
    
    // Reconstruct the updated contents
    let updatedContents = lines.joined(separator: "\n")
    
    // Write the updated contents back to the file
    try updatedContents.write(to: fileURL, atomically: true, encoding: .utf8)
  }
  
}
