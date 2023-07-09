//
//  DailyCheck.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

struct DailyCheck {
  private static let lastCheckedDateKey = "LastCheckedDate"
  
  static var lastCheckedDate: Date? {
    get {
      return UserDefaults.standard.object(forKey: lastCheckedDateKey) as? Date
    }
    set {
      UserDefaults.standard.set(newValue, forKey: lastCheckedDateKey)
    }
  }
  
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
