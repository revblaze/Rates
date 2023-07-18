//
//  Utility+TableView.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import Foundation

extension Utility {
  
  static let dateFormats = ["yyyy-MM-dd", "yyyy-dd-MM", "dd-MM-yyyy", "MM-dd-yyyy",
                            "yyyy/MM/dd", "yyyy/dd/MM", "dd/MM/yyyy", "MM/dd/yyyy",
                            "MMMM dd, yyyy", "dd MMMM, yyyy"]
  
  /// Checks if the given string can be converted to a date.
  ///
  /// - Parameter dateString: The string to check.
  /// - Returns: A Boolean value indicating whether the string can be converted to a date.
  static func isDateString(_ dateString: String) -> Bool {
    let dateFormats = Utility.dateFormats
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    for format in dateFormats {
      formatter.dateFormat = format
      if formatter.date(from: dateString) != nil {
        return true
      }
    }
    
    return false
  }
  
  /// Checks if the given string can be converted to a number with two decimal places.
  ///
  /// - Parameter numberString: The string to check.
  /// - Returns: A Boolean value indicating whether the string can be converted to a number with two decimal places.
  static func isNumberWithTwoDecimalsString(_ numberString: String) -> Bool {
    let components = numberString.components(separatedBy: ".")
    
    if components.count == 2, components[1].count == 2, Double(numberString) != nil {
      return true
    }
    
    return false
  }
  
  /// Checks if the given string is a valid currency code.
  ///
  /// - Parameter currencyString: The string to check.
  /// - Returns: A Boolean value indicating whether the string is a valid currency code.
  static func isCurrencyCode(_ currencyString: String) -> Bool {
    return Locale.commonISOCurrencyCodes.contains(currencyString.uppercased())
  }
  
  /// This function takes an input string and removes any characters that are not a number, period, or minus ("-").
  /// It returns the cleaned string if it's not empty; otherwise, it returns nil.
  ///
  /// - Parameter cellString: The string to clean.
  /// - Returns: The cleaned string, or nil if the cleaned string is empty.
  static func removeAlphaAndParseAmount(_ cellString: String) -> String? {
    let cleanedString = cellString.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
    return cleanedString.isEmpty ? nil : cleanedString
  }
  
}
