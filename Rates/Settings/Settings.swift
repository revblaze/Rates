//
//  Settings.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

let defaults = UserDefaults.standard

// MARK: Keys
/// Keys enum contains all the keys for the UserDefaults.
enum Keys: String, CaseIterable {
  case exchangeRatesUrl
  case customExchangeRatesUrl
  case appHasLaunchedBefore
  
  /// The default value for a given UserDefaults key
  var defaultValue: Any {
    switch self {
    case .exchangeRatesUrl: return Constants.csvUrlString
    case .customExchangeRatesUrl: return ""
    case .appHasLaunchedBefore: return false
    }
  }
}

// MARK: Settings
/// The Settings struct contains all the UserDefaults used in the app.
struct Settings {
  
  /// The URL of the exchange rates.
  static var exchangeRatesUrlString: String? = getStringValue(.exchangeRatesUrl)
  
  /// The default URL of the exchange rates.
  static var defaultExchangeRatesUrlString: String = Keys.exchangeRatesUrl.defaultValue as! String
  
  /// The custom URL of the exchange rates.
  static var customExchangeRatesUrlString: String = Keys.customExchangeRatesUrl.defaultValue as! String
  
  /// Gets called when the app is about to terminate
  static func onAppClose() {
    if exchangeRatesUrlString?.isEmpty ?? true { setDefaultValue(.exchangeRatesUrl) }
  }
  
  /// Returns the value for a given UserDefaults key
  static func getValue(_ forKey: Keys) -> Any {
    return defaults.value(forKey: forKey.rawValue) as Any
  }
  
  /// Saves a value to a given UserDefaults key
  static func saveValue(_ value: Any, forKey: Keys) {
    defaults.set(value, forKey: forKey.rawValue)
  }
  
  /// Returns the default value for any given UserDefaults key
  static func getDefaultValue(_ forKey: Keys) -> Any {
    return forKey.defaultValue
  }
  
  /// Reverts to the default value of the given UserDefaults key
  static func setDefaultValue(_ forKey: Keys) {
    defaults.set(forKey.defaultValue, forKey: forKey.rawValue)
  }
  
  /// Restore all values to their default state
  static func restoreAllDefaults() {
    for key in Keys.allCases {
      setDefaultValue(key)
    }
  }
  
  // MARK: Strings
  /// Returns the value for a given UserDefaults key
  static func getStringValue(_ forKey: Keys) -> String {
    return defaults.string(forKey: forKey.rawValue) ?? forKey.defaultValue as! String
  }
  
  /// Saves a value to a given UserDefaults key
  static func saveStringValue(_ value: String, forKey: Keys) {
    defaults.set(value, forKey: forKey.rawValue)
  }
  
  /// Returns the default value for any given UserDefaults key
  static func getDefaultStringValue(_ forKey: Keys) -> String? {
    return forKey.defaultValue as? String
  }
}
