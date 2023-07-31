//
//  HelpMenu.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import Cocoa

extension AppDelegate {
  
  @IBAction func quickStartGuideMenuItemAction(_ sender: NSMenuItem) {
    presentQuickStartViewAsWindow()
  }
  
  @IBAction func introductionMenuItemAction(_ sender: NSMenuItem) {
    performActionOnViewController { viewController in
      viewController.presentFirstLaunchIntroViewAsSheet()
    }
  }
  
}
