//
//  ViewController+StatusBar.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

extension ViewController {
  
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
  
  func stopStatusBarButtonPulsingAnimation() {
    statusBarButton.layer?.removeAnimation(forKey: "pulse")
    statusBarButtonIsPulsing = false
  }
  
  @IBAction func statusBarRefreshButtonAction(_ sender: NSButton) {
    checkInternetAndUpdateData()
  }
  
}
