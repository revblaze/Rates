//
//  CenteredTextFieldCell.swift
//  Rates
//
//  Created by Justin Bush on 7/15/23.
//

import Cocoa

class CenteredTextFieldCell: NSTextFieldCell {
  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    let newRect = super.drawingRect(forBounds: rect)
    let textSize = self.cellSize(forBounds: rect)
    let heightDelta = newRect.size.height - textSize.height
    if heightDelta > 0 {
      let inset = NSMakeRect(newRect.origin.x, newRect.origin.y + (heightDelta / 2), newRect.size.width, newRect.size.height - heightDelta)
      return inset
    } else {
      return newRect
    }
  }

  override func cellSize(forBounds rect: NSRect) -> NSSize {
    var size = super.cellSize(forBounds: rect)
    let titleSize = self.attributedStringValue.size()
    if size.width > rect.width {
      size.width = rect.width
    }
    if titleSize.height > size.height {
      size.height = titleSize.height
    }
    return size
  }

  override init(textCell string: String) {
    super.init(textCell: string)
    self.lineBreakMode = .byTruncatingTail
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.lineBreakMode = .byTruncatingTail
  }
}
