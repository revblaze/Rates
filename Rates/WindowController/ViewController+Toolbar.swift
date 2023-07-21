//
//  ViewController+Toolbar.swift
//  Rates
//
//  Created by Justin Bush on 7/18/23.
//

import Foundation

extension ViewController {
  
  /// Enables/validates the Toolbar items that were disabled on launch. Is called upon a user importing a file.
  func enableToolbarItemsOnFileLoad() {
    windowController?.enableToolbarItemsOnFileLoad()
  }
  
  /// Disables all of the Toolbar items.
  func disableToolbarButtonsOnFileLoad() {
    windowController?.disableAllToolbarItems()
  }
  
  /// Updates the image of `roundToTwoDecimalPlacesToolbarButton` based on the provided state.
  ///
  /// - Parameter state: A boolean value indicating whether the button should be active or not.
  func updateRoundToTwoDecimalPlacesToolbarButton(toBeActive state: Bool) {
    windowController?.updateRoundToTwoDecimalPlacesToolbarButton(toBeActive: state)
  }
  
  func toggleRoundToTwoDecimalPlaces() {
    if sharedFormattingOptions.roundToTwoDecimalPlaces {
      disableRoundToTwoDecimalPlaces()
    } else {
      enableRoundToTwoDecimalPlaces()
    }
  }
  
  func enableRoundToTwoDecimalPlaces() {
    csvTableView.enableRoundToTwoDecimalPlaces()
  }
  
  func disableRoundToTwoDecimalPlaces() {
    csvTableView.disableRoundToTwoDecimalPlaces()
  }
  
}
