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
  func updateStatusBar(withState: StatusBarState) {
    statusBarState = withState
    statusBarText.stringValue = withState.text
    if let buttonCell = statusBarButton.cell as? NSButtonCell {
      buttonCell.image = NSImage(systemSymbolName: withState.symbolName, accessibilityDescription: nil)
    }
    if withState.shouldAnimateProgressBar {
      startPulsingAnimation()
      statusBarProgressBar.startAnimation(self)
    } else {
      stopStatusBarButtonPulsingAnimation()
      statusBarProgressBar.stopAnimation(self)
    }
    statusBarRefreshButton.isHidden = !withState.refreshButtonShouldBeVisible
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
    checkInternetAndUpdateData()
  }
