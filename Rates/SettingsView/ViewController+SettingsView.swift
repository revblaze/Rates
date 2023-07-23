//
//  ViewController+SettingsView.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import Cocoa
import SwiftUI

extension ViewController {
  
  /// Presents the SettingsView as a sheet.
  func presentSettingsViewAsSheet() {
    let contentView = SettingsView(
      sharedSettings: sharedSettings,
      onDismiss: { [weak self] in
        self?.dismissSettingsView()
      },
      onSave: { [weak self] (clientNeedsNewExchangeRateData) in
        self?.dismissSaveFileView()
        self?.applyNewSettings(clientNeedsNewExchangeRateData: clientNeedsNewExchangeRateData)
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    hostingController.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.settingsViewHostingControllerIdentifier)
    self.presentAsSheet(hostingController)
  }
  
  /// Dismisses the SettingsView if it is currently presented.
  func dismissSettingsView() {
    if let presentedViewController = self.presentedViewControllers?.first(where: { $0.identifier?.rawValue == Constants.settingsViewHostingControllerIdentifier }) {
      self.dismiss(presentedViewController)
    }
  }
  
  func applyNewSettings(clientNeedsNewExchangeRateData: Bool) {
    Debug.log("[applyNewSettings] clientNeedsNewExchangeRateData: \(clientNeedsNewExchangeRateData)")
    
    if clientNeedsNewExchangeRateData {
      // Clear documents directory
      //beginLaunchSession()
    }
  }
  
}

