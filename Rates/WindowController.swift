//
//  WindowController.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Cocoa

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileUrl: URL)
}

/// The main window controller for the application.
class WindowController: NSWindowController, FileSelectionDelegate, NSToolbarDelegate {
  /// Toggles the FilterControlsView to animate in and out.
  @IBOutlet weak var toggleFilterControlViewToolbarButton: NSToolbarItem!
  /// Presents the DataSelectionView as a sheet to determine relevant columns of data to convert.
  @IBOutlet weak var convertToolbarButton: NSToolbarItem!
  /// Exports the current CSVTableView to save as a file on the user's drive.
  @IBOutlet weak var saveFileToolbarButton: NSToolbarItem!
  /// Imports the user's data file to be displayed in the CSVTableView.
  @IBOutlet weak var openFileToolbarButton: NSToolbarItem!
  /// Clears all existing filters on CSVTableView and reverts it back to the original table.
  @IBOutlet weak var clearFiltersToolbarButton: NSToolbarItem!
  
  @IBOutlet weak var toggleRoundToTwoDecimalPlacesToolbarButton: NSToolbarItem!
  
  // MARK: Hidden Items
  @IBOutlet weak var settingsToolbarButton: NSToolbarItem!
  @IBOutlet weak var filterToolbarButton: NSToolbarItem!
  @IBOutlet weak var selectCustomHeaderRowButton: NSToolbarItem!
  
  /// The main view controller of the window.
  lazy var viewController: ViewController = {
    let vc = self.window?.contentViewController as! ViewController
    vc.delegate = self
    return vc
  }()
  
  /// Called when the window finishes loading. Disables toolbar items and sets the toolbar delegate.
  override func windowDidLoad() {
    super.windowDidLoad()
    
    if let toolbar = window?.toolbar { toolbar.delegate = self }
    viewController.windowController = self
    
    disableToolbarItemsOnLaunch()
  }
  
  /// Disables all toolbar items and updates their appearance.
  func disableAllToolbarItems() {
    if let toolbar = window?.toolbar {
      for item in toolbar.items {
        item.action = nil
      }
    }
    validateToolbarItems()
  }
  
  /// Disables toolbar items when the window launches.
  func disableToolbarItemsOnLaunch() {
    disableAllToolbarItems()
  }
  
  /// Enables a specific toolbar button.
  ///
  /// - Parameters:
  ///   - toolbarButton: The toolbar button to enable.
  ///   - action: The action to be performed when the toolbar button is pressed.
  private func enableToolbarButton(_ toolbarButton: NSToolbarItem, action: Selector) {
    toolbarButton.action = action
    toolbarButton.target = self
  }
  
  /// Enables toolbar items when a file is loaded.
  func enableToolbarItemsOnFileLoad() {
    enableToolbarButton(toggleFilterControlViewToolbarButton, action: #selector(toggleFilterControlViewToolbarButtonAction(_:)))
    enableToolbarButton(convertToolbarButton, action: #selector(convertToolbarButtonAction(_:)))
    enableToolbarButton(saveFileToolbarButton, action: #selector(saveFileToolbarButtonAction(_:)))
    enableToolbarButton(openFileToolbarButton, action: #selector(openFileAction(_:)))
    enableToolbarButton(clearFiltersToolbarButton, action: #selector(clearFiltersToolbarButtonAction(_:)))
    enableToolbarButton(toggleRoundToTwoDecimalPlacesToolbarButton, action: #selector(toggleRoundToTwoDecimalPlacesToolbarButtonAction(_:)))
    validateToolbarItems()
  }
  
  /// Enables toolbar items when data is loaded at launch.
  func enableToolbarItemsOnLaunchDataLoad() {
    enableToolbarButton(openFileToolbarButton, action: #selector(openFileAction(_:)))
    validateToolbarItems()
  }
  
  /// Updates the image of `roundToTwoDecimalPlacesToolbarButton` based on the provided state.
  ///
  /// - Parameter state: A boolean value indicating whether the button should be active or not.
  func updateRoundToTwoDecimalPlacesToolbarButton(toBeActive state: Bool) {
    let symbolName = state ? "dollarsign.circle.fill" : "dollarsign.circle"
    let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
    
    toggleRoundToTwoDecimalPlacesToolbarButton.image = symbolImage
  }
  
  /// Opens a file selection when the open file toolbar button is pressed.
  @IBAction func openFileAction(_ sender: Any) {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  /// Reverts changes to the table view when the clear filters toolbar button is pressed.
  @IBAction func clearFiltersToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.revertTableViewChanges)
  }
  
  /// Filters App Store Connect sales when the filter App Store Connect sales toolbar button is pressed.
  @IBAction func filterAppStoreConnectSales(_ sender: Any) {
    performActionOnViewController(action: viewController.filterAppStoreConnectSales)
  }
  
  /// Selects a custom header row from the table when the select custom header row toolbar button is pressed.
  @IBAction func selectCustomHeaderRowFromTable(_ sender: Any) {
    performActionOnViewController(action: viewController.selectCustomHeaderForTableView)
  }
  
  /// Toggles the filter control view when the toggle filter control view toolbar button is pressed.
  @IBAction func toggleFilterControlViewToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.toggleFilterControlsView)
  }
  
  /// Converts toolbar button action when the convert toolbar button is pressed.
  @IBAction func convertToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.presentDataSelectionViewAsSheet)
  }
  
  /// Saves the table view as a file when the save file toolbar button is pressed.
  @IBAction func saveFileToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.saveTableViewAsFile)
  }
  
  /// Toggles rounding to two decimal places when the toggle round to two decimal places toolbar button is pressed.
  @IBAction func toggleRoundToTwoDecimalPlacesToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.toggleRoundToTwoDecimalPlaces)
  }
  
  /// Calls the file selection in the view controller.
  func callOpenFileSelection() {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  /// Processes the selected file URL.
  ///
  /// - Parameters:
  ///   - viewController: The view controller where the file was selected.
  ///   - fileUrl: The URL of the selected file.
  func fileSelected(_ viewController: ViewController, fileUrl: URL) {
    Debug.log("[WindowController.fileSelected] fileUrl: \(fileUrl)")
  }
  
  /// Performs an action on the view controller.
  ///
  /// - Parameter action: The action to perform.
  private func performActionOnViewController(action: () -> ()) {
    action()
  }
  
  /// Validates toolbar items to update their appearance.
  func validateToolbarItems() {
    if let toolbar = window?.toolbar { toolbar.validateVisibleItems() }
  }
  
}


