//
//  Utility.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

struct Utility {
  
  static func writeDataToFile(data: String, fileName: String) throws -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let csvFileURL = documentsDirectory.appendingPathComponent(fileName)
    try data.write(to: csvFileURL, atomically: true, encoding: .utf8)
    return csvFileURL
  }
  
  static func randomString(length: Int) -> String {
    let letters = Constants.alphaNumericString
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
}
