//
//  AppMenu.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import Cocoa

extension AppDelegate {
  
  func enableAllLaunchMenuItems() {
    enableAppMenuItems()
  }
  
  func enableAppMenuItems() {
    enableMenuItem(settingsMenuItem, action: #selector(settingsMenuItemAction(_:)))
  }
  
  @IBAction func settingsMenuItemAction(_ sender: Any) {
    Debug.log("[settingsMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.presentSettingsViewAsSheet()
    }
  }
  
}
