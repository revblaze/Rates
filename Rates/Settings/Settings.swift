//
//  Settings.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

let defaults = UserDefaults.standard

// MARK: Keys
enum Keys: String, CaseIterable {
  case exchangeRatesUrl
  case customExchangeRatesUrl
  
  /// The default value for a given UserDefaults key
  var defaultValue: String {
    switch self {
    case .exchangeRatesUrl: return "https://www.bis.org/statistics/full_xru_d_csv_row.zip"
    case .customExchangeRatesUrl: return ""
    }
  }
}

// MARK: Settings
struct Settings {
  
  static let exchangeRatesUrl = getValue(.exchangeRatesUrl)
  static let defaultExchangeRatesUrl = Keys.exchangeRatesUrl.defaultValue
  static var customExchangeRatesUrl = Keys.customExchangeRatesUrl.defaultValue
  
  /// Gets called when the app is about to terminate
  static func onAppClose() {
    if exchangeRatesUrl.isBlank { setDefaultValue(.exchangeRatesUrl) }
  }
  
  /// Returns the value for a given UserDefaults key
  static func getValue(_ forKey: Keys) -> String {
    return forKey.rawValue
  }
  /// Saves a value to a given UserDefaults key
  static func saveValue(_ value: String, forKey: Keys) {
    defaults.set(value, forKey: forKey.rawValue)
  }
  
  /// Reverts to the default value of the given UserDefaults key
  static func setDefaultValue(_ forKey: Keys) {
    defaults.set(forKey.defaultValue, forKey: forKey.rawValue)
  }
  
  /// Restore all values to their default state
  static func restoreAllDefaults() {
    for key in Keys.allCases {
      if key.rawValue != key.defaultValue {
        setDefaultValue(key)
      }
    }
  }
  
}
