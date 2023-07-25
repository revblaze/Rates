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
        Debug.log("[FileDropBox] Dropped file URL: \(fileURL)")
        self.passFileUrlToTableAndUpdateSharedData(fileURL)
      }
      
      // Add a callback function to print an error message for invalid file types
      self.dragDropOverlayView?.onInvalidFileDropped = { fileURL in
        Debug.log("[FileDropBox] Invalid file type: \(fileURL.pathExtension). Allowed file types are: \(FileExtensions.all.joined(separator: ", "))")
      }
      
      // Create the NSImageView
      let imageView = DragPassThroughImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.image = NSImage(named: NSImage.Name("FileDropBox"))
      imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
      imageView.isEditable = false
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
  
  /// Hides the file drop box by fading out the overlay view and then removing it.
  func hideFileDropBox() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Fade out the overlay view
      NSAnimationContext.runAnimationGroup({ context in
        // Set the duration of the animation
        context.duration = 0.4
        
        // Animate the alpha value of the overlay view to 0 (completely transparent)
        self.dragDropOverlayView?.animator().alphaValue = 0
      }, completionHandler: {
        // Remove the overlay view after the animation is completed
        self.dragDropOverlayView?.removeFromSuperview()
        self.dragDropOverlayView = nil
      })
    }
  }
  
}



/// `DragDropOverlayView` is a subclass of `NSView` that supports drag and drop operations.
/// It includes callbacks for handling file drops and invalid file drops.
class DragDropOverlayView: NSView {
  
  /// A closure that is called when a file is dropped onto the view.
  /// The closure is passed the `URL` of the dropped file.
  var onFileDropped: ((URL) -> Void)?
  
  /// A closure that is called when an invalid file is dropped onto the view.
  /// The closure is passed the `URL` of the dropped file.
  var onInvalidFileDropped: ((URL) -> Void)?
  
  /// This method is called when a drag operation enters the view.
  /// It returns a `NSDragOperation` that specifies which drag operations are supported.
  /// It also changes the background color to a dark overlay when a valid file type is being dragged.
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    guard let board = sender.draggingPasteboard.pasteboardItems?.first,
          let fileURLString = board.string(forType: .fileURL),
          let fileURL = URL(string: fileURLString),
          fileURL.hasFileExtension() != nil
    else {
      return []
    }
    
    self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
    return .copy
  }
  
  /// This method is called when the drag operation leaves the view.
  /// It changes the background color back to its original color.
  override func draggingExited(_ sender: NSDraggingInfo?) {
    self.layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  //// This method is called when a drag operation is performed on the view.
  /// It checks if the dropped file has a valid extension and then calls the appropriate callback.
  /// It also changes the background color back to its original color.
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    self.layer?.backgroundColor = NSColor.clear.cgColor
    guard let board = sender.draggingPasteboard.pasteboardItems?.first,
          let fileURLString = board.string(forType: .fileURL),
          let fileURL = URL(string: fileURLString)
    else {
      return false
    }
    
    // Check if the file extension is allowed
    if fileURL.hasFileExtension() != nil {
      // Call the callback function with the dropped file URL
      onFileDropped?(fileURL)
      return true
    } else {
      onInvalidFileDropped?(fileURL)
      return false
    }
  }
  
  
}


/// `DragPassThroughImageView` is a subclass of `NSImageView` that passes drag and drop operations
/// through to its superview.
class DragPassThroughImageView: NSImageView {
  /// This method is called when a drag operation enters the image view.
  /// It passes the operation to the superview and returns the result.
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    return superview?.draggingEntered(sender) ?? .generic
  }
  
  /// This method is called when a drag operation is performed on the image view.
  /// It passes the operation to the superview and returns the result.
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    return superview?.performDragOperation(sender) ?? false
  }
}
