//
//  ViewController+FirstLaunchIntroView.swift
//  Rates
//
//  Created by Justin Bush on 7/31/23.
//

import Cocoa
import SwiftUI

extension ViewController {
  
  /// Presents the FirstLaunchIntroView as a sheet.
  func presentFirstLaunchIntroViewAsSheet() {
    let contentView = FirstLaunchIntroView(
      sharedSettings: sharedSettings,
      onDismiss: { [weak self] in
        self?.dismissFirstLaunchIntroView()
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    hostingController.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.firstLaunchIntroViewHostingControllerIdentifier)
    self.presentAsSheet(hostingController)
  }
  
  /// Dismisses the FirstLaunchIntroView if it is currently presented.
  func dismissFirstLaunchIntroView() {
    if let presentedViewController = self.presentedViewControllers?.first(where: { $0.identifier?.rawValue == Constants.firstLaunchIntroViewHostingControllerIdentifier }) {
      self.dismiss(presentedViewController)
    }
  }
  
}
