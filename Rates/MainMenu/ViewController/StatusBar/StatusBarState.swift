//
//  StatusBarState.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Foundation

/// Enumeration representing the various states of the status bar.
enum StatusBarState {
  /// Loading the exchange rate SQLite file (data.db)
  case loading
  /// The exchange rate database is up to date. Default state of the app, post-launch.
  case upToDate
  /// The latest exchange rate data is currently being downloaded.
  case isCurrentlyUpdating
  /// Failed to update with the latest exhange rate data; likely due to being unable to reach the database provider.
  case failedToUpdate
  /// The user is not connected to the internet and there could be new exchange rate data available, but unable to check.
  case noConnectionAndPrefersUpdate
  /// The user is not connected to the internet and there is no db present. App should be disabled.
  case noConnectionAndNoDb
  /// Parsing the user's file data and populating the tableView with said data.
  case loadingUserData
  /// Unable to parse user's file data. Potentially a corrupt file or unknown format.
  case failedToLoadUserData
  
  /// The text description associated with the state.
  var text: String {
    switch self {
    case .loading: return "Loading exchange rate database."
    case .upToDate: return "Up to date."
    case .isCurrentlyUpdating: return "Downloading the latest exchange rate data. This may take a few moments."
    case .failedToUpdate: return "An error occured while updating. Please click the refresh icon to try again."
    case .noConnectionAndPrefersUpdate: return "New exchange rate data may be available, but we were unable to check. Please check your network connection and try again."
    case .noConnectionAndNoDb: return "Please connect to the internet to download the latest exchange rate data."
    case .loadingUserData: return "Rendering data from file. This will only take a moment."
    case .failedToLoadUserData: return "We encountered a problem with your file. Please try again."
    }
  }
  
  /// The system symbol name associated with the state.
  var symbolName: String {
    switch self {
    case .loading: return "ellipsis"
    case .upToDate: return "checkmark.seal.fill"
    case .isCurrentlyUpdating: return "icloud.and.arrow.down.fill"//"wifi"
    case .failedToUpdate: return "wifi.exclamationmark"
    case .noConnectionAndPrefersUpdate: return "exclamationmark.icloud.fill"//"exclamationmark.triangle"
    case .noConnectionAndNoDb: return "wifi.exclamationmark"
    case .loadingUserData: return "hourglass"
    case .failedToLoadUserData: return "exclamationmark.triangle.fill"
    }
  }
  
  /// Indicates whether the refresh button should be visible in the state.
  var refreshButtonShouldBeVisible: Bool {
    switch self {
    case .loading: return false
    case .upToDate: return false
    case .isCurrentlyUpdating: return false
    case .failedToUpdate: return true
    case .noConnectionAndPrefersUpdate: return true
    case .noConnectionAndNoDb: return true
    case .loadingUserData: return false
    case .failedToLoadUserData: return false
    }
  }
  
  /// Indicates whether the progress bar should be animated in the state.
  var shouldAnimateProgressBar: Bool {
    switch self {
    case .loading: return true
    case .upToDate: return false
    case .isCurrentlyUpdating: return true
    case .failedToUpdate: return false
    case .noConnectionAndPrefersUpdate: return false
    case .noConnectionAndNoDb: return false
    case .loadingUserData: return true
    case .failedToLoadUserData: return false
    }
  }
  
}
