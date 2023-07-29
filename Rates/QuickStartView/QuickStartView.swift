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
  
  var body: some View {
    VStack {
      ScrollView {
        
        ExpandableSectionView(title: "Section 1 Title", contentViews: [StepImageCaptionRow(header: "Section 1, Header 1", imageString: "sample", caption: "This is caption text for section 1 header 1.", imgWidth: 1956, imgHeight: 888), StepImageCaptionRow(header: "Section 1, Header 2", imageString: "some_sample_img", caption: "This is caption text for section 1 header 2.", imgWidth: 1000, imgHeight: 1000)], expanded: true)
        ExpandableSectionView(title: "Section 2 Title", contentViews: [StepImageCaptionRow(header: "Section 2, Header 1", imageString: "new_sample", caption: "This is caption text for section 2 header 1.", imgWidth: 900, imgHeight: 888)])
        ExpandableSectionView(title: "Section 3 Title", contentViews: [StepImageCaptionRow(header: "Section 3, Header 1", imageString: "img_random2", caption: "This is caption text for section 3 header 1.", imgWidth: 500, imgHeight: 400)])
        
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
    }
    .padding()
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
      
      if let imageString = imageString {
        Image(imageString)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.vertical, Constants.quickStartViewGenericPadding)
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
        .padding(.top, Constants.quickStartViewGenericPadding)
      }
      
    }
    .padding(Constants.quickStartViewGenericPadding)
    
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
