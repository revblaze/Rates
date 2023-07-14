//
//  URLExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

extension URL {
  /// Reads the contents of the URL as a string using the UTF-8 encoding.
  ///
  /// - Throws: An error if there is an issue reading the contents of the URL or decoding it as a string.
  /// - Returns: The contents of the URL as a string.
  func readAsString() throws -> String {
    return try String(contentsOf: self, encoding: .utf8)
  }
}
