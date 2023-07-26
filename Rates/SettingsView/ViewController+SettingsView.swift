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
    
    let newCutOffYearInt = Int(newCutOffYear) ?? Constants.defaultCutOffYearInt
    let currentCutOffYearInt = Int(sharedSettings.cutOffYear) ?? Constants.defaultCutOffYearInt
    
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
  
  
  func promptClearApplicationCacheAndTableDataAlert() {
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
        self.clearApplicationCacheAndTableData()
        
      default:
        break
      }
    }
  }
  
  func clearApplicationCacheAndTableData() {
    csvTableView.removeAllData()
    _ = Utility.clearApplicationSupportDirectory()
    _ = Utility.clearApplicationDocumentsDirectory()
    sharedHeaders.reset()
    sharedData.reset()
    sharedFormattingOptions.reset()
    // Start launch session
    beginLaunchSession()
  }
  
}


extension SharedHeaders {
  func reset() {
    self.availableCurrencyCodeHeaders = []
    self.availableHeaders = []
    self.suggestedHeaders = [nil]
  }
}

extension SharedData {
  func reset() {
    self.sqliteUrl = nil
    self.inputUserFile = nil
    self.inputUserFileExtension = nil
    self.outputUserFile = nil
    self.outputUserFileName = ""
    self.outputUserFileExtension = .csv
    self.outputUserFileFormat = .csv
    self.saveAllInputDataToOutputFile = false
    self.saveRoundedConversionValuesToOutputFile = false
  }
}

extension SharedFormattingOptions {
  func reset() {
    self.roundToTwoDecimalPlaces = false
    self.hideEmptyColumns = true
    self.hideIrrelevantColumns = true
  }
}

extension SharedSettings {
  func reset() {
    self.showExchangeRateDataOnLaunch = false
    
    // Reset the cutOffYear both in the class and in UserDefaults
    let defaultCutOffYear = Constants.defaultCutOffYearString
    self.cutOffYear = defaultCutOffYear
    UserDefaults.standard.set(defaultCutOffYear, forKey: "cutOffYear")
  }
}
