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
      startStatusBarButtonPulsingAnimation()
      statusBarProgressBar.startAnimation(self)
    } else {
      stopStatusBarButtonPulsingAnimation()
      statusBarProgressBar.stopAnimation(self)
    }
    statusBarRefreshButton.isHidden = !withState.refreshButtonShouldBeVisible
  }


  func startStatusBarButtonPulsingAnimation() {
    guard !statusBarButtonIsPulsing else { return }
    
    let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = 1.0
    animation.toValue = 0.2
    animation.duration = 1.0
    animation.autoreverses = true
    animation.repeatCount = .infinity
    statusBarButton.layer?.add(animation, forKey: "pulse")
    
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
