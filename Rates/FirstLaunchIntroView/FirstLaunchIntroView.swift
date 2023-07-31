//
//  FirstLaunchIntroView.swift
//  Rates
//
//  Created by Justin Bush on 7/31/23.
//

import SwiftUI

struct FirstLaunchIntroViewData {
  
  static let slides = [slide1, slide2, slide3, slide4, slide5]
  
  static let slide1 = ["IntroSlide1", "Import a spreadsheet or data file with transaction dates, amounts and currencies."]
  static let slide2 = ["IntroSlide2", "Rates will automatically attempt to identify the correct columns. Click Convert!"]
  static let slide3 = ["IntroSlide3", "Select the currency you wish to convert to. You can do this multiple times!"]
  static let slide4 = ["IntroSlide4", "Tidy up your new sheet with filters – totally optional!"]
  static let slide5 = ["IntroSlide5", "Save your file in whatever format works best for you."]
  
}

struct FirstLaunchIntroView: View {
  @ObservedObject var sharedSettings: SharedSettings
  var onDismiss: () -> Void
  
  @State private var currentSlideIndex = 0
  
  var body: some View {
    VStack {
      HStack {
        Image(FirstLaunchIntroViewData.slides[currentSlideIndex][0])
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
      .frame(width: 600, height: 400)
      
      HStack {
        
        Button(action: {
          if currentSlideIndex > 0 {
            currentSlideIndex -= 1
          }
        }) {
          Image(systemName: "chevron.left.square.fill")
            .font(.system(size: 24))
            .foregroundColor(currentSlideIndex > 0 ? .secondary : .secondary.opacity(0.4))
        }
        .buttonStyle(.plain)
        
        Spacer()
        
        Text(FirstLaunchIntroViewData.slides[currentSlideIndex][1])
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
        
        Button(action: {
          if currentSlideIndex < FirstLaunchIntroViewData.slides.count - 1 {
            currentSlideIndex += 1
          }
        }) {
          Image(systemName: "chevron.right.square.fill")
            .font(.system(size: 24))
            .foregroundColor(currentSlideIndex < FirstLaunchIntroViewData.slides.count - 1 ? .secondary : .secondary.opacity(0.4))
        }
        .buttonStyle(.plain)
        
      }
      .padding(.vertical, 6)
      .padding(.horizontal, 12)
      
      Divider()
      
      HStack {
        Button("Don't Show This Again") {
          onDismiss()
        }
        .keyboardShortcut(.cancelAction)
        .largeButton()
        
        Spacer()
        
        Button("Dismiss") {
          onDismiss()
        }
        .keyboardShortcut(.defaultAction)
        .largeButton(foregroundColor: .white, backgroundColor: .accentColor, pressedColor: .accentColor.opacity(0.6))
      }
      .padding(.bottom, 6)
      .padding(.vertical, 6)
      .padding(.horizontal, 12)
    }
    .frame(minWidth: 600)
  }
}
