//
//  ImportFileTemplateView.swift
//  Rates
//
//  Created by Justin Bush on 7/10/23.
//

import Cocoa

class ImportFileTemplateView: NSViewController {
  private let fileUrl: URL
  private let withDetection: FileTemplates
  private var completionHandler: ((FileTemplates) -> Void)?
  
  init(fileUrl: URL, withDetection: FileTemplates) {
    self.fileUrl = fileUrl
    self.withDetection = withDetection
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = NSView() // Replace with your custom view initialization
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Perform any additional setup here
    
    // Call the dismissSheetView function after some time (just for demonstration purposes)
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      let fileTemplates = self.dismissSheetView()
      self.completionHandler?(fileTemplates)
    }
  }
  
  func dismissSheetView() -> FileTemplates {
    // Replace with your logic to dismiss the sheet and return the desired value
    return withDetection
  }
  
  func waitForDismissal(on sheetWindow: NSWindow) -> FileTemplates {
    let semaphore = DispatchSemaphore(value: 0)
    var result: FileTemplates = withDetection
    
    completionHandler = { fileTemplates in
      result = fileTemplates
      semaphore.signal()
    }
    
    sheetWindow.beginSheet(self.view.window!,
                           completionHandler: { response in
      // Dismiss the sheet and handle the response if needed
      sheetWindow.endSheet(self.view.window!, returnCode: response)
    })
    
    semaphore.wait()
    
    return result
  }
}
