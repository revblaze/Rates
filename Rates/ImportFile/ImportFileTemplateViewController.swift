//
//  ImportFileTemplateViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

class ImportFileTemplateViewController: NSViewController {
  var fileUrl: URL?
  var withDetection: FileTemplates?
  
  @IBOutlet private var fileNameTextField: NSTextField!
  @IBOutlet private var fileFormatTextField: NSTextField!
  @IBOutlet private var comboBox: NSComboBox!
  @IBOutlet private var continueButton: NSButton!
  
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
  
  @IBAction func cancelSheetButtonAction(_ sender: Any?) {
    dismissSheet()
    stopAnimatingStatusBar()
  }
  
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
  
  
  
  private func dismissSheet() {
    view.window?.sheetParent?.endSheet(view.window!, returnCode: .OK)
  }
  
  private func passDataToTableView(fileUrl: URL, withTemplate: FileTemplates) {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.passDataToTableView(fileUrl: fileUrl, withTemplate: withTemplate)
    }
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    startAnimatingStatusBar()
    // Assuming your continueButton outlet is connected
    view.window?.makeFirstResponder(continueButton)
  }
  
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
  
  func startAnimatingStatusBar() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .loadingUserData)
    }
  }
  func stopAnimatingStatusBar() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .upToDate)
    }
  }
  func stopAnimatingStatusBarWithError() {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.updateStatusBar(withState: .failedToLoadUserData)
    }
  }
  
}
