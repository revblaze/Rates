//
//  FileMenu.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import Cocoa

extension AppDelegate {
  
  func enableFileMenuItems() {
    enableMenuItem(openFileMenuItem, action: #selector(openFileMenuItemAction(_:)))
    enableMenuItem(printFileMenuItem, action: #selector(printFileMenuItemAction(_:)))
  }
  
  func enableSaveFileMenuItem() {
    enableMenuItem(saveFileMenuItem, action: #selector(saveFileMenuItemAction(_:)))
  }
  
  @IBAction func openFileMenuItemAction(_ sender: Any) {
    Debug.log("[openFileMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.openFileSelection()
    }
  }
  
  @IBAction func saveFileMenuItemAction(_ sender: Any) {
    Debug.log("[saveFileMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.presentSaveFileViewAsSheet()
    }
  }
  
  @IBAction func printFileMenuItemAction(_ sender: Any) {
    Debug.log("[printFileMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.csvTableView.printTableView()
    }
  }
  
}
