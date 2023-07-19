//
//  ViewController+Toolbar.swift
//  Rates
//
//  Created by Justin Bush on 7/18/23.
//

import Foundation

extension ViewController {
  
  /// Enables/validates the Toolbar items that were disabled on launch. Is called upon a user importing a file.
  func enableToolbarButtonsOnFileLoad() {
    windowController?.enableToolbarItemsOnFileLoad()
  }
  
  
  func enableRoundToTwoSignificantDigits() {
    csvTableView.enableRoundToTwoDecimalPlaces()
  }
  
  func disableRoundToTwoSignificantDigits() {
    csvTableView.disableRoundToTwoDecimalPlaces()
  }
  
}
