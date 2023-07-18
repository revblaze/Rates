//
//  ViewController+DataSelectionViewHostingController.swift
//  Rates
//
//  Created by Justin Bush on 7/18/23.
//

import Cocoa
import SwiftUI

extension ViewController {
  
  /// Presents the DataSelectionView as a sheet.
  func presentDataSelectionViewAsSheet() {
    let contentView = DataSelectionView(
      sharedHeaders: sharedHeaders,
      sharedFormattingOptions: sharedFormattingOptions,
      onDismiss: { [weak self] in
        self?.dismissDataSelectionView()
      },
      onConvert: { [weak self] (dates, amounts, currencies, amountsCurrenciesCombined, toCurrency) in
        self?.dismissDataSelectionView()
        self?.performConversionUsingColumnWithHeaders(dates: dates, amounts: amounts, currencies: currencies, amountsCurrenciesCombined: amountsCurrenciesCombined, toCurrency: toCurrency)
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    hostingController.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.dataSelectionViewHostingControllerIdentifier)
    self.presentAsSheet(hostingController)
  }
  
  /// Dismisses the DataSelectionView if it is currently presented.
  func dismissDataSelectionView() {
    if let presentedViewController = self.presentedViewControllers?.first(where: { $0.identifier?.rawValue == Constants.dataSelectionViewHostingControllerIdentifier }) {
      self.dismiss(presentedViewController)
    }
  }
  
}
