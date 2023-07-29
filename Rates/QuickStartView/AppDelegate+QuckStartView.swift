//
//  AppDelegate+QuckStartView.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import Foundation
import SwiftUI

extension AppDelegate {
  
  /// Presents the QuickStartView as a new window.
  func presentQuickStartViewAsWindow() {
    // Create an instance of your SwiftUI view
    let contentView = QuickStartView(dataModel: DataModel(filename: "QuickStartData"))
    
    // Create a new window
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName(Constants.quickStartViewHostingControllerIdentifier)
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
    
    // Set the title of the window
    window.title = "Quick Start"
    
    // Set minimum window size
    window.minSize = NSSize(width: 300, height: 400)
    
    // Assign the window to a property on AppDelegate to prevent it from being deallocated
    self.quickStartWindow = window
  }
  
}
