//
//  ViewController+FileDropBox.swift
//  Rates
//
//  Created by Justin Bush on 7/24/23.
//

import Cocoa

extension ViewController: NSDraggingDestination {
  
  /// Shows a file drop box by creating an overlay view with an `NSImageView` in the center.
  func showFileDropBox() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Create the overlay view
      self.dragDropOverlayView = DragDropOverlayView()
      self.dragDropOverlayView?.wantsLayer = true
      
      // Register the drag types
      self.dragDropOverlayView?.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
      
      // Add a callback function to print the dropped file URL
      self.dragDropOverlayView?.onFileDropped = { fileURL in
        print("Dropped file URL: \(fileURL)")
      }
      
      // Create the NSImageView
      let imageView = DragPassThroughImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.image = NSImage(named: NSImage.Name("FileDropBox"))
      imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
      self.dragDropOverlayView?.addSubview(imageView)
      
      // Add the overlay view to the main view
      self.view.addSubview(self.dragDropOverlayView!, positioned: .below, relativeTo: self.statusBarViewContainer)
      
      // Set up constraints for the overlay view
      self.dragDropOverlayView?.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        self.dragDropOverlayView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.dragDropOverlayView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        self.dragDropOverlayView!.topAnchor.constraint(equalTo: self.view.topAnchor),
        self.dragDropOverlayView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        
        // Center the image view within the overlay view, raise it 20 points higher, and constrain its size
        imageView.centerXAnchor.constraint(equalTo: self.dragDropOverlayView!.centerXAnchor),
        imageView.centerYAnchor.constraint(equalTo: self.dragDropOverlayView!.centerYAnchor, constant: -20),
        imageView.widthAnchor.constraint(equalToConstant: 348),
        imageView.heightAnchor.constraint(equalToConstant: 223)
      ])
    }
  }
  
  /// Hides the file drop box by removing the overlay view.
  func hideFileDropBox() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Remove the overlay view
      self.dragDropOverlayView?.removeFromSuperview()
      self.dragDropOverlayView = nil
    }
  }
}

class DragDropOverlayView: NSView {
  
  // Add a callback property that takes a URL as a parameter
  var onFileDropped: ((URL) -> Void)?
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    return .copy
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let board = sender.draggingPasteboard.pasteboardItems?.first,
          let fileURLString = board.string(forType: .fileURL),
          let fileURL = URL(string: fileURLString)
    else {
      return false
    }
    
    // Call the callback function with the dropped file URL
    onFileDropped?(fileURL)
    return true
  }
}

class DragPassThroughImageView: NSImageView {
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    return superview?.draggingEntered(sender) ?? .generic
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    return superview?.performDragOperation(sender) ?? false
  }
}
