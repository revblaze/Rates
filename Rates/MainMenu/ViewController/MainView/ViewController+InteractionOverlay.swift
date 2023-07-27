//
//  ViewController+InteractionOverlay.swift
//  Rates
//
//  Created by Justin Bush on 7/24/23.
//

import Cocoa

extension ViewController {
  
  /// Disables interaction with the main view by adding a transparent gray overlay over all views except the status bar.
  func disableMainViewInteraction() {
    Debug.log("debugMainViewInteraction()")
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.windowController?.disableAllToolbarItems()
      // Create the overlay view
      self.overlayView = OverlayView()
      self.overlayView?.wantsLayer = true
      self.overlayView?.layer?.backgroundColor = NSColor.darkGray.withAlphaComponent(0.6).cgColor
      
      // Add the overlay view to the main view
      self.view.addSubview(self.overlayView!, positioned: .below, relativeTo: self.statusBarViewContainer)
      
      // Set up constraints for the overlay view
      self.overlayView?.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        self.overlayView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.overlayView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        self.overlayView!.topAnchor.constraint(equalTo: self.view.topAnchor),
        self.overlayView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
      ])
    }
  }
  
  /// Enables interaction with the main view by removing the transparent gray overlay.
  func enableMainViewInteraction() {
    Debug.log("enableMainViewInteraction()")
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      //self.enableToolbarItemsOnFileLoad()
      
      if userHasPreviouslyLoadedInputFileThisSession {
        self.enableToolbarItemsOnFileLoad()
      } else {
        self.enableToolbarItemsForPostLaunchState()
      }
      
      
      // Remove the overlay view
      self.overlayView?.removeFromSuperview()
      self.overlayView = nil
    }
  }
  
  
}

class OverlayView: NSView {
  override func mouseDown(with event: NSEvent) {
    // Do nothing, just consume the event
  }
}
