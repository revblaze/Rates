//
//  FirstLaunchIntroView.swift
//  Rates
//
//  Created by Justin Bush on 7/31/23.
//

import SwiftUI

struct FirstLaunchIntroViewData {
  
  static let slidesData = [slide1, slide2, slide3, slide4]
  
  static let slide1 = ["slide1ImageFileName", "slide1 description text"]
  static let slide2 = ["slide2ImageFileName", "slide2 description text"]
  static let slide3 = ["slide3ImageFileName", "slide3 description text"]
  static let slide4 = ["slide4ImageFileName", "slide4 description text"]
  
}

struct FirstLaunchIntroView: View {
  @ObservedObject var sharedSettings: SharedSettings
  var onDismiss: () -> Void
  
  init(sharedSettings: SharedSettings, onDismiss: @escaping () -> Void) {
    self.sharedSettings = sharedSettings
    self.onDismiss = onDismiss
  }
  
  var body: some View {
    VStack {
      HStack {
        Image("IntroScreen1")
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
      .frame(width: 600, height: 400)
      
      HStack {
        
        Button(action: {
          // slidesData[currentSlide-1] : back one slide slide if available, do nothing if not
        }) {
          Image(systemName: "chevron.left.square.fill")
            .font(.system(size: 24))
            // if one slide back is not available (currentSlide == slidesData.first) set foregroundColor .secondary.opacity(0.4)
            // otherwise, set foregroundColor .secondary
            .foregroundColor(.secondary.opacity(0.4))
        }
        .buttonStyle(.plain)
        
        Spacer()
        
        Text("Describing text here")
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
        
        Button(action: {
          // slidesData[currentSlide+1] : forward one slide slide if available, do nothing if not
        }) {
          Image(systemName: "chevron.right.square.fill")
            .font(.system(size: 24))
          // if one slide forward is not available (currentSlide == slidesData.last) set foregroundColor .secondary.opacity(0.4)
          // otherwise, set foregroundColor .secondary
            .foregroundColor(.secondary)
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

//struct FirstLaunchIntroView_Previews: PreviewProvider {
//  static var previews: some View {
//    FirstLaunchIntroView()
//  }
//}
