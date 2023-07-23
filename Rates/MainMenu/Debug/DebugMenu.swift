//
//  DebugMenu.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

extension AppDelegate {
  
  /// Sets the Debug menu's `isHidden` and `isEnabled` properties based on the current environment (see Configuration.swift)
  func initDebugMenu() {
    debugMenu.isHidden = !Debug.isActive
    debugMenu.isEnabled = Debug.isActive
  }
  
  private func debugUpdateStatusBar(withStatus: StatusBarState) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.updateStatusBar(withState: withStatus)
  }
  
  @IBAction func debugUpdateStatusBarLoading(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .loading)
  }
  @IBAction func debugUpdateStatusBarUpToDate(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .upToDate)
  }
  @IBAction func debugUpdateStatusBarIsCurrentlyUpdating(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .isCurrentlyUpdating)
  }
  @IBAction func debugUpdateStatusBarFailedToUpdate(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .failedToUpdate)
  }
  @IBAction func debugUpdateStatusBarNoConnectionAndPrefersUpdate(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .noConnectionAndPrefersUpdate)
  }
  @IBAction func debugUpdateStatusBarNoConnectionAndNoDb(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .noConnectionAndNoDb)
  }
  @IBAction func debugUpdateStatusBarLoadingUserData(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .loadingUserData)
  }
  @IBAction func debugUpdateStatusBarFailedToLoadUserData(_ sender: NSMenuItem) {
    debugUpdateStatusBar(withStatus: .failedToLoadUserData)
  }
  
  
  @IBAction func debugSlideInFilterControlsView(_ sender: NSMenuItem) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.slideInFilterControlsView()
  }
  @IBAction func debugSlideOutFilterControlsView(_ sender: NSMenuItem) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.slideOutFilterControlsView()
  }
  
  
  @IBAction func debugPresentDataSelectionViewAsSheet(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.presentDataSelectionViewAsSheet()
    }
  }
  
  @IBAction func debugDisableMainViewInteraction(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.disableMainViewInteraction()
    }
  }
  @IBAction func debugEnableMainViewInteraction(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.enableMainViewInteraction()
    }
  }
  
  @IBAction func debugEnableRoundToTwoDecimalPlaces(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.enableRoundToTwoDecimalPlaces()
    }
  }
  @IBAction func debugDisableRoundToTwoDecimalPlaces(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.disableRoundToTwoDecimalPlaces()
    }
  }
  
  
//  private func performActionOnViewController(action: @escaping (ViewController) -> Void) {
//    guard let viewController = mainWindow.contentViewController as? ViewController else {
//      return
//    }
//    
//    DispatchQueue.main.async {
//      action(viewController)
//    }
//  }
  
  
}
