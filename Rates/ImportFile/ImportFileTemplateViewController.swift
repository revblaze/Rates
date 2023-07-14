//
//  ImportFileTemplateViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

/// A view controller that handles the interface for importing file templates.
class ImportFileTemplateViewController: NSViewController {
  /// The URL of the file.
  var fileUrl: URL?
  /// The detected file template.
  var withDetection: FileTemplates?
  
  @IBOutlet private var fileNameTextField: NSTextField!
  @IBOutlet private var fileFormatTextField: NSTextField!
  @IBOutlet private var comboBox: NSComboBox!
  @IBOutlet private var continueButton: NSButton!
  
  /// Performs additional setup after loading the view.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Perform any additional setup here
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: FileTemplates.all)
    
    if let withDetection = withDetection {
      let selectedValue = withDetection.rawValue
      comboBox.selectItem(withObjectValue: selectedValue)
    }
    
    if let fileName = fileUrl?.lastPathComponent {
      fileNameTextField.stringValue = fileName
    }
    
    if let fileExtensionType = fileUrl?.hasFileExtension() {
      fileFormatTextField.stringValue = fileExtensionType.fullFormatName
    }
    fileFormatTextField.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
  }
  
  /// Dismisses the sheet and stops the animation of the status bar when the cancel button is clicked.
  ///
  /// - Parameter sender: The button that initiated the action.
  @IBAction func cancelSheetButtonAction(_ sender: Any?) {
    dismissSheet()
    stopAnimatingStatusBar()
  }
  
  /// Passes data to the table view and dismisses the sheet when the dismiss button is clicked.
  ///
  /// - Parameter sender: The button that initiated the action.
  @IBAction func dismissSheetButtonAction(_ sender: Any) {
    guard let fileUrl = fileUrl else {
      Debug.log("[dismissSheetButtonAction: missing fileUrl, unable to pass data.")
      dismissSheet()
      stopAnimatingStatusBarWithError()
      return
    }
    
    dismissSheet()
    
    if let selectedValue = comboBox.objectValueOfSelectedItem as? String,
       let template = FileTemplates(rawValue: selectedValue) {
      passDataToTableView(fileUrl: fileUrl, withTemplate: template)
    }
  }
  
  /// Dismisses the sheet.
  private func dismissSheet() {
    view.window?.sheetParent?.endSheet(view.window!, returnCode: .OK)
  }
  
  /// Passes data from a file with a given URL and file template to the table view.
  ///
  /// - Parameters:
  ///   - fileUrl: The URL of the file.
  ///   - withTemplate: The file template.
  private func passDataToTableView(fileUrl: URL, withTemplate: FileTemplates) {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.passDataToTableView(fileUrl: fileUrl, withTemplate: withTemplate)
    }
  }
  
  /// Starts the animation of the status bar when the view appears.
  override func viewDidAppear() {
    super.viewDidAppear()
    
    startAnimatingStatusBar()
    // Assuming your continueButton outlet is connected
    view.window?.makeFirstResponder(continueButton)
  }
  
  /// Handles key down events.
  ///
  /// - Parameter event: The event object that encapsulates the key down event.
  override func keyDown(with event: NSEvent) {
    if let firstResponder = view.window?.firstResponder as? NSView, firstResponder == continueButton {
      if event.keyCode == 36 {
        // "Enter" key code is 36
        continueButton.performClick(self)
      } else {
        super.keyDown(with: event)
      }
    } else {
      super.keyDown(with: event)
    }
  }
  
  /// Starts the animation of the status bar.
  func startAnimatingStatusBar() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .loadingUserData)
    }
  }
  /// Stops the animation of the status bar.
  func stopAnimatingStatusBar() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .upToDate)
    }
  }
  /// Stops the animation of the status bar with an error.
  func stopAnimatingStatusBarWithError() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .failedToLoadUserData)
    }
  }
  
}
