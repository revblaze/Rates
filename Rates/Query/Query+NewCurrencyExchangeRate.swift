//
//  NewCurrencyExchangeRate.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import Foundation
import SQLite

extension Query {
  
  /**
   Converts the specified amount from USD to the specified currency on the given date.
   
   - Parameters:
   - amountString: The amount in USD as a string.
   - code: The currency code to convert to.
   - date: The date for the conversion.
   
   - Returns: The converted amount in the new currency as a double, or nil if the conversion fails.
   
   - Important:
   - The function relies on `Query` class for currency conversion and `Debug` class for logging.
   */
  static func valueInNewCurrency(fromUsdAmount amountString: String, toCurrencyCode code: String, onDate date: String) -> Double? {
    let newCurrencyExchangeRate = newCurrencyExchangeRate(toCurrency: code, onDate: date)
    
    if let amount = Double(amountString) {
      return amount * newCurrencyExchangeRate
    }
    
    Debug.log("[Query.valueInNewCurrency] Unable to convert amount to double.")
    return nil
  }
  
  /**
   Retrieves the exchange rate for the specified currency on the given date.
   
   - Parameters:
   - code: The currency code to get the exchange rate for.
   - date: The date for the exchange rate.
   
   - Returns: The exchange rate as a double.
   
   - Important:
   - The function relies on `Query` class for database access and `Debug` class for logging.
   - Make sure to handle the case where the exchange rate is not found.
   */
  static func newCurrencyExchangeRate(toCurrency code: String, onDate date: String) -> Double {
    // Define the list of date formats
    let dateFormats = Utility.dateFormats
    
    // Define a date formatter
    let dateFormatter = DateFormatter()
    
    // Try each date format
    for format in dateFormats {
      dateFormatter.dateFormat = format
      
      // If the date string can be parsed, convert it to the desired format
      if var date = dateFormatter.date(from: date) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var attempts = 0
        while attempts < 5 {
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
                let result = row[0] as? String
                
                // If the result is not "NaN" or empty, return it as a double
                if result != "NaN" && result != "" {
                  return Double(result ?? "0.0") ?? 0.0
                }
              }
            } else {
              Debug.log("[Query.usdExchangeRate] SQLite URL is nil")
            }
          } catch {
            Debug.log("[Query.usdExchangeRate] Database connection or query execution failed: \(error)")
          }
          
          // If the result was "NaN" or empty, decrement the date and try again
          date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
          attempts += 1
        }
      }
    }
    // If no formats match or connection fails, return 0.0
    return 0.0
  }
  
}
