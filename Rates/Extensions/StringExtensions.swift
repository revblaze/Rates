//
//  StringExtensions.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

extension String {
  /// Returns true if the String is either empty or explicitly contains white spaces
  var isBlank: Bool {
    return allSatisfy({ $0.isWhitespace })
  }
}
