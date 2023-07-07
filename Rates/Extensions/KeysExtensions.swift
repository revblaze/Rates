//
//  KeysExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

extension Keys {
  static var allCases: [Self] {
    return Mirror(reflecting: self).children.compactMap { $0.value as? Self }
  }
}
