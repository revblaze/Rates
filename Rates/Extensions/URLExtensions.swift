//
//  URLExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

extension URL {
  func readAsString() throws -> String {
    return try String(contentsOf: self, encoding: .utf8)
  }
}
