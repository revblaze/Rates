//
//  Utils.swift
//  Rates
//
//  Created by Justin Bush on 7/11/23.
//

import Foundation

struct Utils {
  
  static func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
}
