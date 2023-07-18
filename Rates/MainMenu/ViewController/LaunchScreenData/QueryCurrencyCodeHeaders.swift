//
//  QueryCurrencyCodeHeaders.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import Foundation
import SQLite

extension ViewController {
  
  /// Updates the available currency code headers by querying an SQLite file, cleaning the results,
  /// and assigning the cleaned headers to the sharedHeaders.availableCurrencyCodeHeaders property.
  /// The SQLite file path is obtained using the sqliteUrl() function.
  ///
  /// This function retrieves the currency code headers from the SQLite file, cleans the headers by
  /// removing invalid entries and reordering based on priority, and then updates the sharedHeaders
  /// data structure with the cleaned headers.
  ///
  /// Note: The sharedHeaders data structure is assumed to be accessible within the current scope.
  /// If the sqliteUrl() function returns nil or encounters any errors during the querying process,
  /// the availableCurrencyCodeHeaders will not be updated.
  func updateAvailableCurrencyCodeHeaders() {
    if let sqliteUrl = Query.sqliteUrl() {
      
      let queriedCurrencyCodeHeaders = queryCurrencyCodeHeaders(sqliteFileUrl: sqliteUrl)
      let cleanedCurrencyCodeHeaders = cleanCurrencyCodeArray(queriedCurrencyCodeHeaders)
      
      sharedHeaders.availableCurrencyCodeHeaders = cleanedCurrencyCodeHeaders
    }
    
  }
  
  /// Additionally, it reorders the resulting array with priority given to specific top currencies.
  ///
  /// - Parameter currencyCodes: An array of currency codes.
  /// - Returns: A cleaned and reordered array of currency codes.
  func cleanCurrencyCodeArray(_ currencyCodes: [String]) -> [String] {
      let validCurrencyCodes = currencyCodes.filter { $0.count == 3 }
      var outputCurrencies = validCurrencyCodes
      
      let topCurrencies = ["AUD", "CAD", "CNY", "EUR", "GBP", "JPY", "USD"]
      
      if !outputCurrencies.isEmpty {
          outputCurrencies.insert("–––", at: 0)
          
          for currency in topCurrencies.reversed() {
              if let index = outputCurrencies.firstIndex(of: currency) {
                  outputCurrencies.remove(at: index)
                  outputCurrencies.insert(currency, at: 0)
              }
          }
      }
      
      return outputCurrencies
  }
  
  /// Queries an SQLite file for all the headers of each column in a table and returns them as an array.
  ///
  /// - Parameters:
  ///   - sqliteFileUrl: The URL of the SQLite file.
  /// - Returns: An array containing the headers of each column.
  func queryCurrencyCodeHeaders(sqliteFileUrl: URL) -> [String] {
    var headers: [String] = []
    
    do {
      let db = try Connection(sqliteFileUrl.path)
      let statement = try db.prepare("PRAGMA table_info(\(Constants.sqliteTableName))")
      
      for row in statement {
        if let header = row[1] as? String {
          headers.append(header)
        }
      }
    } catch {
      print("Error querying SQLite file: \(error)")
    }
    
    return headers
  }
  
}
