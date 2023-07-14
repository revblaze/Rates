
//
//  DailyCheck.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

/// A structure with a static method for checking if an action should be performed based on the date.
struct DailyCheck {
  private static let lastCheckedDateKey = "LastCheckedDate"
  
  /// Gets and sets the last checked date in `UserDefaults`.
  static var lastCheckedDate: Date? {
    get {
      return UserDefaults.standard.object(forKey: lastCheckedDateKey) as? Date
    }
    set {
      UserDefaults.standard.set(newValue, forKey: lastCheckedDateKey)
    }
  }
  
  /// Checks if an action should be performed based on the date.
  ///
  /// - Returns: `true` if the action should be performed, or `false` if no action is required.
  static func shouldPerformAction() -> Bool {
    let currentDate = Date()
    
    if let lastDate = lastCheckedDate, Calendar.current.isDate(currentDate, inSameDayAs: lastDate) {
      // Same day, no action required
      return false
    } else {
      // New day, update the last checked date and perform the action
      lastCheckedDate = currentDate
      return true
    }
  }
  
}
