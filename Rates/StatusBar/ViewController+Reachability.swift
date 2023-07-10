//
//  ViewController+Reachability.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa
import SystemConfiguration

extension ViewController {
  
  func noInternetConnection() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let reachability = withUnsafePointer(to: &zeroAddress, {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        SCNetworkReachabilityCreateWithAddress(nil, $0)
      }
    }) else {
      return true
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(reachability, &flags) {
      return true
    }
    
    let isReachable = flags.contains(.reachable)
    let requiresConnection = flags.contains(.connectionRequired)
    
    return !(isReachable && !requiresConnection)
  }
  
}
