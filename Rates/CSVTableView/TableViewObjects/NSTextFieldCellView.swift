//
//  NSTextFieldCellView.swift
//  Rates
//
//  Created by Justin Bush on 7/21/23.
//

import Cocoa

/// A custom text field cell view with a custom intrinsic content size.
class NSTextFieldCellView: NSTextField {
  override var intrinsicContentSize: NSSize {
    return NSSize(width: CGFloat.greatestFiniteMagnitude, height: super.intrinsicContentSize.height)
  }
}
