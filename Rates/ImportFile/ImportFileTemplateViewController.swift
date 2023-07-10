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
  @IBOutlet private var comboBox: NSComboBox!
  
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
  }
  
  @IBAction func dismissSheetButtonAction(_ sender: Any) {
    guard let fileUrl = fileUrl else {
      // Missing fileUrl, unable to pass data
      dismissSheet()
      return
    }
    
    if let selectedValue = comboBox.objectValueOfSelectedItem as? String,
       let template = FileTemplates(rawValue: selectedValue) {
      passDataToTableView(fileUrl: fileUrl, withTemplate: template)
    }
    
    dismissSheet()
  }
  
  private func dismissSheet() {
    view.window?.sheetParent?.endSheet(view.window!, returnCode: .OK)
  }
  
  private func passDataToTableView(fileUrl: URL, withTemplate: FileTemplates) {
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.passDataToTableView(fileUrl: fileUrl, withTemplate: withTemplate)
    }
  }
}
