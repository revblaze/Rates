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
  /// A Boolean value indicating whether the URL is valid.
  ///
  /// This property checks if the URL has a scheme and a host, which are basic components of a well-formed URL.
  /// Depending on specific needs, this check might need to be made more or less rigorous.
  var isValid: Bool {
    return self.scheme != nil && self.host != nil
  }
}
