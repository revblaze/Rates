//
//  QueryUsdExchangeRate.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import Cocoa
import SQLite

extension Query {
  
  /// Converts the given amount of currency to its equivalent value in USD based on the specified exchange rate.
  ///
  /// - Parameters:
  ///   - code: The currency code representing the currency to be converted.
  ///   - amountString: The string representation of the amount of currency to be converted.
  ///   - date: The date on which the conversion should be based.
  /// - Returns: The value in USD as a `Double` if the conversion is successful; `nil` otherwise.
  static func valueInUsd(currencyCode code: String, amountOfCurrency amountString: String, onDate date: String) -> Double? {
    let usdExchangeRate = usdExchangeRate(forCurrency: code, onDate: date)
    
    if let amount = Double(amountString) {
      return amount*usdExchangeRate
    }
    
    Debug.log("[Query.valueInUsd] Unable to convert amount to double.")
    return nil
    
  }
  
  /// Retrieves the exchange rate of the specified currency to USD on the given date.
  ///
  /// - Parameters:
  ///   - code: The currency code representing the currency for which the exchange rate is needed.
  ///   - date: The date on which the exchange rate should be retrieved.
  /// - Returns: The exchange rate as a `Double`.
  static func usdExchangeRate(forCurrency code: String, onDate date: String) -> Double {
    // Define the list of date formats
    let dateFormats = Utility.dateFormats
    
    // Define a date formatter
    let dateFormatter = DateFormatter()
    
    // Try each date format
    for format in dateFormats {
      dateFormatter.dateFormat = format
      
      // If the date string can be parsed, convert it to the desired format
      if let date = dateFormatter.date(from: date) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        
        do {
          // Connect to the SQLite database if the URL is available
          if let url = Query.sqliteUrl()?.path {
            let db = try Connection(url)
            
            // Construct the SQL query
            let query = "SELECT \(code) FROM data WHERE Currency = ?"
            
            // Prepare the statement
            let stmt = try db.prepare(query)
            
            // Bind the date to the statement
            _ = stmt.bind(formattedDate)
            
            // Run the query and fetch the result
            if let row = stmt.next() {
              return Double(row[0] as? String ?? "0.0") ?? 0.0
            }
          } else {
            Debug.log("[Query.usdExchangeRate] SQLite URL is nil")
          }
        } catch {
          Debug.log("[Query.usdExchangeRate] Database connection or query execution failed: \(error)")
        }
      }
    }
    
    // If no formats match or connection fails, return 0.0
    return 0.0
  }
  
}
