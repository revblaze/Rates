//
//  ViewController+StatusBar.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

/// Extension of the `ViewController` class to add additional methods for updating the status bar.
extension ViewController {
  
  /// Updates the status bar with a given state.
  ///
  /// - Parameter withState: The state to update the status bar with.
  func updateStatusBar(withState state: StatusBarState) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.statusBarState = state
      self.statusBarText.stringValue = state.text
      if let buttonCell = self.statusBarButton.cell as? NSButtonCell {
        buttonCell.image = NSImage(systemSymbolName: state.symbolName, accessibilityDescription: nil)
      }
      if state.shouldAnimateProgressBar {
        self.startPulsingAnimation()
        self.statusBarProgressBar.startAnimation(self)
      } else {
        self.stopStatusBarButtonPulsingAnimation()
        self.statusBarProgressBar.stopAnimation(self)
      }
      self.statusBarRefreshButton.isHidden = !state.refreshButtonShouldBeVisible
    }
  }
  
  /// Starts a pulsing animation on the status bar button.
  func startPulsingAnimation() {
    guard !statusBarButtonIsPulsing else { return }
    
    // Opacity animation
    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.fromValue = 1.0
    opacityAnimation.toValue = 0.2
    opacityAnimation.duration = 1.0
    opacityAnimation.autoreverses = true
    opacityAnimation.repeatCount = .infinity
    
    statusBarButton.layer?.add(opacityAnimation, forKey: "pulse")
    statusBarButtonIsPulsing = true
  }
  
  /// Stops the pulsing animation on the status bar button.
  func stopStatusBarButtonPulsingAnimation() {
    statusBarButton.layer?.removeAnimation(forKey: "pulse")
    statusBarButtonIsPulsing = false
  }
  
  /// Checks the internet connection and updates the data when the status bar refresh button is clicked.
  ///
  /// - Parameter sender: The button that initiated the action.
  @IBAction func statusBarRefreshButtonAction(_ sender: NSButton) {
    performAppropriateStatusBarRefreshButtonAction()
  }
  
  /// Trigger the appropriate action for the refresh/reload button based on the current `StatusBarState`.
  func performAppropriateStatusBarRefreshButtonAction() {
    
    if statusBarState == .failedToLoadUserData {
      // If failed to load user file, supply them with a new input file prompt.
      openFileSelection()
    } else if statusBarState == .failedToUpdate || statusBarState == .noConnectionAndNoDb || statusBarState == .noConnectionAndPrefersUpdate {
      // Check internet connection again and try to download exchange rate data.
      checkInternetAndUpdateData()
    }
    // Else, refresh button should have no action.
  }
  
}
