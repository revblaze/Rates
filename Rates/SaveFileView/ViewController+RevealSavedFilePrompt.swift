//
//  ViewController+RevealSavedFilePrompt.swift
//  Rates
//
//  Created by Justin Bush on 7/21/23.
//

import Cocoa

extension ViewController {
  
  /// Alert user of successfully saved file and display "Reveal in Finder" option
  func alertFileDidSave(withOutputUrl: URL) {
    let a = NSAlert()
    a.messageText = "File Saved"
    a.informativeText = "Your file has been saved successfully!"
    a.addButton(withTitle: "OK")
    a.addButton(withTitle: "Reveal in Finder")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        Debug.log("User did acknowledge successful file conversion")
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        Debug.log("User did select: Reveal in Finder")
        self.showInFinder(url: withOutputUrl)
      }
    })
  }
  
  /// Open Finder with selected file at designated `url`
  func showInFinder(url: URL) {
    if url.isDirectory {
      NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    } else {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }
  }
  
}

extension URL {
  /// Returns true if URL in question is a valid directory
  var isDirectory: Bool {
    return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
