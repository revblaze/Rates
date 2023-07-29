//
//  QuickStartView.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import SwiftUI

extension Constants {
  
  static let quickStartViewGenericPadding = CGFloat(8)
  
}

struct QuickStartView: View {
  var body: some View {
    VStack {
      ScrollView {
        
        ExpandableSectionView(title: "Section 1 Title", contentView: StepImageCaptionRow(header: "Section 1, Header 1", imageString: "sample", caption: "This is caption text."), expanded: true)
        ExpandableSectionView(title: "Section 2 Title", contentView: StepImageCaptionRow(header: "Section 2, Header 1", imageString: "sample", caption: "This is caption text."))
        ExpandableSectionView(title: "Section 3 Title", contentView: StepImageCaptionRow(header: "Section 3, Header 1", imageString: "sample", caption: "This is caption text."))
      }
    }
    .frame(minWidth: 300, minHeight: 400)
  }
}


// MARK: Expandable Section
struct ExpandableSectionView: View {
  var title: String
  var contentView: StepImageCaptionRow
  var expanded: Bool?
  
  @State private var isExpanded: Bool
  
  init(title: String, contentView: StepImageCaptionRow, expanded: Bool? = nil) {
    self.title = title
    self.contentView = contentView
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
        VStack {
          contentView
        }
        .transition(.opacity)
      }
    }
    .padding()
  }
}



// MARK: Step Image Caption Row
struct StepImageCaptionRow: View {
  var header: String
  var imageString: String?
  var caption: String?
  
  @State private var showImagePopover: Bool = false
  
  var body: some View {
    VStack {
      
      HStack {
        Text(header)
          .bold()
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
              .frame(maxWidth: 600, maxHeight: 600)  // Set your maximum width and height here
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
}
