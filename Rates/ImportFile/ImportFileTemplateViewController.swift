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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Perform any additional setup here
  }
  
  @IBAction func dismissSheetButtonAction(_ sender: Any) {
    guard let fileUrl = fileUrl, let withDetection = withDetection else {
      // Missing fileUrl or withDetection, unable to pass data
      dismissSheet()
      return
    }
    
    if let presentingViewController = presentingViewController as? ViewController {
      presentingViewController.passDataToTableView(fileUrl: fileUrl, withTemplate: withDetection)
    }
    
    dismissSheet()
  }
  
  private func dismissSheet() {
    view.window?.sheetParent?.endSheet(view.window!, returnCode: .OK)
  }
}
