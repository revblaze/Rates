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
  
  /**
   Extracts the currency code from a given string.
   
   - Parameters:
   - cell: The string to extract the currency code from. The currency code will be removed from this string.
   
   - Returns: The extracted currency code, or an empty string if no currency code was found.
   
   - Important:
   - The function assumes that the currency codes are three letters long and may be located anywhere within the string.
   - The function modifies the input string, removing the currency code if one was found.
   - The function capitalizes the currency code before returning it.
   */
  static func extractCurrencyCode(_ cell: inout String, usingCurrencyCodes codes: [String]) -> String {
    // Define all possible currency codes
    let currencyCodes = codes
    
    // Iterate over all currency codes
    for code in currencyCodes {
      // Check if the cell contains the currency code (ignoring case)
      if let range = cell.range(of: code, options: .caseInsensitive) {
        // Remove the currency code from the cell
        cell.removeSubrange(range)
        // Return the capitalized currency code
        return code.uppercased()
      }
    }
    
    // If no currency code was found, return an empty string
    return ""
  }
  
  /// Checks if the column should be skipped based on the header, identifier, and headers array.
  ///
  /// - Parameters:
  ///   - headerText: The text of the header cell.
  ///   - identifier: The raw value of the NSUserInterfaceItemIdentifier for the column.
  ///   - headers: An array of headers that should not be hidden.
  /// - Returns: A Boolean value indicating whether the column should be skipped.
  static func shouldSkipColumn(headerText: String, identifier: String, headers: [String]) -> Bool {
    return headers.contains(headerText) || ["CurrencyCodeColumn", "ToUsdColumn"].contains(identifier) || identifier.hasPrefix("ToNewCurrency-")
  }
  
  /// Checks if all the cells in the column are empty.
  ///
  /// - Parameters:
  ///   - data: The table data.
  ///   - columnIndex: The index of the column.
  /// - Returns: A Boolean value indicating whether all the cells in the column are empty.
  static func isColumnEmpty(data: [[String]], columnIndex: Int) -> Bool {
    for row in data {
      // If the columnIndex is out of bounds, skip this row
      if row.count <= columnIndex {
        continue
      }
      let cell = row[columnIndex]
      if !cell.isEmpty {
        return false
      }
    }
    return true
  }
  
  
}
