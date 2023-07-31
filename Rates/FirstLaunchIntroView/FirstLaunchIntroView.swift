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
          // Back one slide if available, do nothing if not
          // Set color to .foregroundColor(.accentColor) if back one slide is available, set to .foregroundColor(.secondary) if not
        }) {
          Image(systemName: "chevron.left.square.fill")
            .font(.system(size: 18))
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        
        Spacer()
        
        Text("Describing text here")
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
        
        Button(action: {
          // Forward one slide if available, do nothing if not
          // Set color to .foregroundColor(.accentColor) if forward one slide is available, set to .foregroundColor(.secondary) if not
        }) {
          Image(systemName: "chevron.right.square.fill")
            .font(.system(size: 18))
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        
      }
      .padding(6)
      
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
