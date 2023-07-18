//
//  ViewController+Animations.swift
//  Rates
//
//  Created by Justin Bush on 7/18/23.
//

import Cocoa

extension ViewController {
  
  /// Toggles the FilterControlsView sidebar to animate in or out, depending on its current state.
  func toggleFilterControlsView() {
    if filterControlsViewIsHidden {
      slideInFilterControlsView()
    } else {
      slideOutFilterControlsView()
    }
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by Constants.filterControlsViewWidth such that is visible on the screen.
   */
  func slideInFilterControlsView() {
    filterControlsConstraint.constant = 0
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }, completionHandler: {
      self.filterControlsViewIsHidden = false
    })
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by Constants.filterControlsViewWidth such that it is once again out of view entirely.
   */
  func slideOutFilterControlsView() {
    filterControlsConstraint.constant = Constants.filterControlsViewWidth
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }, completionHandler: {
      self.filterControlsViewIsHidden = true
    })
  }
  
}
