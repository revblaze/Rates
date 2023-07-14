//
//  KeysExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

extension Keys {
  /// Returns an array containing all the cases of the enumeration.
  ///
  /// - Returns: An array of all the cases of the enumeration.
  static var allCases: [Self] {
    return Mirror(reflecting: self).children.compactMap { $0.value as? Self }
  }
}
