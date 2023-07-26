//
//  ViewController+SettingsView.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import Cocoa
import SwiftUI

extension ViewController {
  
  /// Presents the SettingsView as a sheet.
  func presentSettingsViewAsSheet() {
    let contentView = SettingsView(
      sharedSettings: sharedSettings,
      onDismiss: { [weak self] in
        self?.dismissSettingsView()
      },
      onSave: { [weak self] (newCutOffYear) in
        self?.dismissSettingsView()
        self?.applyNewSettings(newCutOffYear: newCutOffYear)
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    hostingController.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.settingsViewHostingControllerIdentifier)
    self.presentAsSheet(hostingController)
  }
  
  /// Dismisses the SettingsView if it is currently presented.
  func dismissSettingsView() {
    if let presentedViewController = self.presentedViewControllers?.first(where: { $0.identifier?.rawValue == Constants.settingsViewHostingControllerIdentifier }) {
      self.dismiss(presentedViewController)
    }
  }
  
  func applyNewSettings(newCutOffYear: String) {
    var clientNeedsNewExchangeRateData = false
    
    let newCutOffYearInt = Int(newCutOffYear) ?? 2016
    let currentCutOffYearInt = Int(sharedSettings.cutOffYear) ?? 2016
    
    Debug.log("[applyNewSettings] newCutOffYear: \(newCutOffYear)")
    Debug.log("[applyNewSettings] compare: \(newCutOffYearInt) < \(currentCutOffYearInt)")
    
    // If new cutOffYear is less than current year, get new
    if newCutOffYearInt < currentCutOffYearInt {
      clientNeedsNewExchangeRateData = true
    }
    
    // If there is a newly selected cutOffYear, clear client data and fetch new data.
    if newCutOffYear != sharedSettings.cutOffYear {
      sharedSettings.cutOffYear = newCutOffYear
      // Client needs to download data for new year range.
      if clientNeedsNewExchangeRateData {
        // If the documents directory was successfully cleared.
        if Utility.clearApplicationDocumentsDirectory() {
          downloadDataForNewCutOffYearSettings(newCutOffYear: newCutOffYear)
        }
      }
    }
  }
  
  /// Clear Application Documents Directory and download new exchange rate data.
  func downloadDataForNewCutOffYearSettings(newCutOffYear: String) {
    sharedSettings.cutOffYear = newCutOffYear
    // If the documents directory was successfully cleared.
    if Utility.clearApplicationDocumentsDirectory() {
      //csvTableView.removeAllData()
      beginLaunchSession()
    }
  }
  
  
  func clearApplicationCacheAndTableData() {
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Clear Application Data"
      alert.informativeText = "Are you sure you want to clear Rates application cache and data?\n\nAny unsaved table data will be lost."
      alert.alertStyle = .informational
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Delete")
      
      alert.buttons.last?.hasDestructiveAction = true
      
      let modalResult = alert.runModal()
      
      switch modalResult {
      case .alertFirstButtonReturn:
        Debug.log("User clicked 'Cancel'")
        // Add code to download update
      case .alertSecondButtonReturn:
        Debug.log("User clicked 'Delete'")
        self.csvTableView.removeAllData()
        _ = Utility.clearApplicationSupportDirectory()
        _ = Utility.clearApplicationDocumentsDirectory()
        self.beginLaunchSession()
        
      default:
        break
      }
    }
  }
  
}

