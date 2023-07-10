//
//  StatusBarState.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

enum StatusBarState {
  
  case loading
  case upToDate
  case isCurrentlyUpdating
  case failedToUpdate
  case noConnectionAndPrefersUpdate
  case noConnectionAndNoDb
  
  var text: String {
    switch self {
    case .loading: return "Loading exchange rate database."
    case .upToDate: return "Up to date."
    case .isCurrentlyUpdating: return "Downloading latest exchange rate data. This may take a few moments."
    case .failedToUpdate: return "An error occured while updating. Please click the icon to try again."
    case .noConnectionAndPrefersUpdate: return "New exchange rate data may be available, but we were unable to check. Please check your network connection and try again."
    case .noConnectionAndNoDb: return "Please connect to the internet to download the latest exchange rate data."
    }
  }
  
  var symbolName: String {
    switch self {
    case .loading: return "ellipsis"
    case .upToDate: return "checkmark.seal.fill"
    case .isCurrentlyUpdating: return "icloud.and.arrow.down.fill"//"wifi"
    case .failedToUpdate: return "wifi.exclamationmark"
    case .noConnectionAndPrefersUpdate: return "exclamationmark.icloud.fill"//"exclamationmark.triangle"
    case .noConnectionAndNoDb: return "wifi.exclamationmark"
    }
  }
  
}
