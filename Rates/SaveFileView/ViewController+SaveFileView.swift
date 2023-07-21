//
//  ViewController+SaveFileView.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import Cocoa
import SwiftUI

extension ViewController {
  
  /// Presents the DataSelectionView as a sheet.
  func presentSaveFileViewAsSheet() {
    let contentView = SaveFileView(
      sharedData: sharedData,
      onDismiss: { [weak self] in
        self?.dismissSaveFileView()
      },
      onSave: { [weak self] (fileName, fileExtension, fileFormat) in
        self?.dismissSaveFileView()
        self?.saveUserFile(withName: fileName, fileExtension: fileExtension, dataFormat: fileFormat)
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    hostingController.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.saveFileViewHostingControllerIdentifier)
    self.presentAsSheet(hostingController)
  }
  
  /// Dismisses the DataSelectionView if it is currently presented.
  func dismissSaveFileView() {
    if let presentedViewController = self.presentedViewControllers?.first(where: { $0.identifier?.rawValue == Constants.saveFileViewHostingControllerIdentifier }) {
      self.dismiss(presentedViewController)
    }
  }
  
  func saveUserFile(withName name: String, fileExtension: FileExtensions, dataFormat: FileExtensions) {
    Debug.log("[saveUserFile] \(name).\(fileExtension) [\(dataFormat.fullFormatName)] ")
    
    // TODO: present save file prompt
  }
  
}
