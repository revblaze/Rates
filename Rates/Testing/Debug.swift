//
//  Debug.swift
//  Rates
//
//  Created by Justin Bush on 7/8/23.
//

import Foundation

struct Debug {
  
  static let isActive = true
  
  static func log(_ text: Any) {
    if isActive { print(text) }
  }
  
}
