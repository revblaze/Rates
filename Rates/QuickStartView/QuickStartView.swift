//
//  QuickStartView.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import SwiftUI

extension Constants {
  
  static let quickStartViewGenericPadding = CGFloat(8)
  static let maxImagePopoverWidthAndHeight = CGFloat(800)
  
}

struct QuickStartView: View {
  @ObservedObject var dataModel: DataModel
  
  var body: some View {
    VStack {
      ScrollView {
        ForEach(dataModel.sections, id: \.title) { section in
          ExpandableSectionView(
            title: section.title,
            contentViews: section.content.map { StepImageCaptionRow(header: $0.header, imageString: $0.imageString, caption: $0.caption, imgWidth: $0.imgWidth, imgHeight: $0.imgHeight) },
            expanded: section.expanded
          )
        }
        .padding(.vertical)
      }
    }
    .frame(minWidth: 300, minHeight: 400)
  }
}



// MARK: Expandable Section
struct ExpandableSectionView: View {
  var title: String
  var contentViews: [StepImageCaptionRow]
  var expanded: Bool?
  
  @State private var isExpanded: Bool
  
  init(title: String, contentViews: [StepImageCaptionRow], expanded: Bool? = nil) {
    self.title = title
    self.contentViews = contentViews
    self.expanded = expanded
    self._isExpanded = State(initialValue: expanded ?? false)
  }
  
  var body: some View {
    VStack {
      
      Button(action: {
        withAnimation {
          isExpanded.toggle()
        }
      }) {
        HStack {
          Text(title)
            .font(.headline)
          Spacer()
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
        }
      }
      .buttonStyle(PlainButtonStyle())
      .frame(maxWidth: .infinity)
      
      if isExpanded {
        ForEach(contentViews, id: \.header) { contentView in
          contentView
        }
        .transition(.opacity)
      }
      
      Divider()
        .padding(.top, Constants.quickStartViewGenericPadding)
    }
    .padding(Constants.quickStartViewGenericPadding)
    .padding(.horizontal, Constants.quickStartViewGenericPadding)
  }
}




// MARK: Step Image Caption Row
struct StepImageCaptionRow: View {
  var header: String
  var imageString: String?
  var caption: String?
  var imgWidth: CGFloat?
  var imgHeight: CGFloat?
  
  @State private var showImagePopover: Bool = false
  
  var body: some View {
    VStack {
      
      HStack {
        Text(header)
          .fixedSize(horizontal: false, vertical: true)
        Spacer()
      }
      
      if let imageString = imageString, NSImage(named: imageString) != nil {
        Image(imageString)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.top, Constants.quickStartViewGenericPadding)
          .onTapGesture {
            showImagePopover = true
          }
          .popover(isPresented: $showImagePopover) {
            Image(imageString)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: calculatePopoverWidth(), maxHeight: calculatePopoverHeight())
          }
      }
      
      if let caption = caption {
        HStack {
          Text(caption)
            .font(.caption)
            .fixedSize(horizontal: false, vertical: true)
          Spacer()
        }
        .padding(.vertical, Constants.quickStartViewGenericPadding)
      }
      
    }
    .padding(.vertical, Constants.quickStartViewGenericPadding)
    
  }
  
  func calculatePopoverWidth() -> CGFloat {
    guard let imgWidth = imgWidth, let imgHeight = imgHeight else {
      return Constants.maxImagePopoverWidthAndHeight
    }
    if imgWidth > imgHeight {
      return Constants.maxImagePopoverWidthAndHeight
    } else {
      return (imgWidth / imgHeight) * Constants.maxImagePopoverWidthAndHeight
    }
  }
  
  func calculatePopoverHeight() -> CGFloat {
    guard let imgWidth = imgWidth, let imgHeight = imgHeight else {
      return Constants.maxImagePopoverWidthAndHeight
    }
    if imgHeight > imgWidth {
      return Constants.maxImagePopoverWidthAndHeight
    } else {
      return (imgHeight / imgWidth) * Constants.maxImagePopoverWidthAndHeight
    }
  }
}
