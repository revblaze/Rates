//
//  LargeButton.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import SwiftUI

struct LargeButtonDemo: View {
  var body: some View {
    Button(action: { } ) {
      Text("Button A")
    }
    .largeButton()
    
    Button(action: { } ) {
      Text("Button B has a long description")
    }
    .largeButton(
      foregroundColor: .blue,
      backgroundColor: .yellow,
      pressedColor: .orange
    )
  }
}

struct NiceButtonStyle: ButtonStyle {
  var foregroundColor: Color
  var backgroundColor: Color
  var pressedColor: Color
  
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .font(.headline)
      .padding(10)
      .padding(.horizontal, 20)
      .foregroundColor(foregroundColor)
      .background(configuration.isPressed ? pressedColor : backgroundColor)
      .cornerRadius(5)
  }
}

extension View {
  func largeButton(
    foregroundColor: Color = .white,
    backgroundColor: Color = .secondary.opacity(0.7),
    pressedColor: Color = .secondary.opacity(0.5)
  ) -> some View {
    self.buttonStyle(
      NiceButtonStyle(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        pressedColor: pressedColor
      )
    )
  }
}


//struct Button_Previews: PreviewProvider {
//    static var previews: some View {
//        Button()
//    }
//}
