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
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    if let toolbar = window?.toolbar { toolbar.delegate = self }
    viewController.windowController = self
    
    disableToolbarItemsOnLaunch()
  }
  
  /// Disables the necessary toolbar items on launch.
  func disableToolbarItemsOnLaunch() {
    toggleFilterControlViewToolbarButton.action = nil
    convertToolbarButton.action = nil
    saveFileToolbarButton.action = nil
    openFileToolbarButton.action = nil
    clearFiltersToolbarButton.action = nil
    toggleRoundToTwoDecimalPlacesToolbarButton.action = nil
  }
  /// Enables the necessary toolbar items once the user has loaded up a file.
  func enableToolbarItemsOnFileLoad() {
    enableToggleFilterControlViewToolbarButton()
    enableConvertToolbarButton()
    enableSaveFileToolbarButton()
    enableClearFiltersToolbarButton()
    enableToggleRoundToTwoDecimalPlacesToolbarButton()
    // Update toolbar item appearance
    validateToolbarItems()
  }
  
  /// Enables the necessary toolbar items once the initial launch data has been loaded.
  func enableToolbarItemsOnLaunchDataLoad() {
    enableOpenFileToolbarButton()
    // Update toolbar item appearance
    validateToolbarItems()
  }
  
  /// Enables the openFileActiont oolbar button item. Called after the initial launch data has been loaded.
  func enableOpenFileToolbarButton() {
    openFileToolbarButton.action = #selector(openFileAction(_:))
    openFileToolbarButton.target = self
  }
  
  /// Enables the toggleFilterControlsView toolbar button item. Called after a file has been imported.
  func enableToggleFilterControlViewToolbarButton() {
    toggleFilterControlViewToolbarButton.action = #selector(toggleFilterControlViewToolbarButtonAction(_:))
    toggleFilterControlViewToolbarButton.target = self
  }
  /// Enables the convert toolbar button item. Called after a file has been imported.
  func enableConvertToolbarButton() {
    convertToolbarButton.action = #selector(convertToolbarButtonAction(_:))
    convertToolbarButton.target = self
  }
  
  func enableClearFiltersToolbarButton() {
    clearFiltersToolbarButton.action = #selector(clearFiltersToolbarButtonAction(_:))
    clearFiltersToolbarButton.target = self
  }
  
  func enableSaveFileToolbarButton() {
    saveFileToolbarButton.action = #selector(saveFileToolbarButtonAction(_:))
    saveFileToolbarButton.target = self
  }
  
  func enableToggleRoundToTwoDecimalPlacesToolbarButton() {
    toggleRoundToTwoDecimalPlacesToolbarButton.action = #selector(toggleRoundToTwoDecimalPlacesToolbarButtonAction(_:))
    toggleRoundToTwoDecimalPlacesToolbarButton.target = self
  }
  
  /// Performs an action on the view controller to open a file selection.
  @IBAction func openFileAction(_ sender: Any) {
    performActionOnViewController(action: viewController.openFileSelection)
  }
  
  /// Performs an action on the view controller to revert changes to the table view.
  @IBAction func clearFiltersToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.revertTableViewChanges)
  }
  
  /// Performs an action on the view controller to filter App Store Connect sales.
  @IBAction func filterAppStoreConnectSales(_ sender: Any) {
    performActionOnViewController(action: viewController.filterAppStoreConnectSales)
  }
  
  /// Performs an action on the view controller to manually select the current table view row as the header row.
  @IBAction func selectCustomHeaderRowFromTable(_ sender: Any) {
    performActionOnViewController(action: viewController.selectCustomHeaderForTableView)
  }
  
  @IBAction func toggleFilterControlViewToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.toggleFilterControlsView)
  }
  @IBAction func convertToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.presentDataSelectionViewAsSheet)
  }
  
  @IBAction func saveFileToolbarButtonAction(_ sender: Any) {
    performActionOnViewController(action: viewController.saveTableViewAsFile)
  }
  
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
    Debug.log("[fileSelected] fileUrl: \(fileUrl)")
    // Process the selected file URL
  }
  
  /// Performs an action on the view controller.
  ///
  /// - Parameter action: The action to perform.
  private func performActionOnViewController(action: () -> ()) {
    action()
  }
  
  func validateToolbarItems() {
    if let toolbar = window?.toolbar { toolbar.validateVisibleItems() }
  }
  
}

