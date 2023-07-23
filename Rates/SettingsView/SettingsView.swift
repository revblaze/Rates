//
//  SettingsView.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import SwiftUI

class SharedSettings: ObservableObject {
  @Published var clientNeedsNewExchangeRateData = false
  
  @Published var cutOffYear: String = "2016"
}

struct SettingsView: View {
  @ObservedObject var sharedSettings: SharedSettings
  var onDismiss: () -> Void
  var onSave: (Bool) -> Void
  
  @State private var selectedYear: String
  @State private var initialYear: String
  
  var body: some View {
    let years = (1950...Calendar.current.component(.year, from: Date())).map { String($0) }.reversed()
    
    VStack {
      HStack {
        Text("Settings")
          .bold()
      }
      .padding()
      
      Divider()
      
      HStack {
        Text("Range of Historical Exchange Rate Data")
          .bold()
      }
      HStack {
        Text("From Present to:")
        Menu(selectedYear) {
          ForEach(years, id: \.self) { year in
            Button(year) {
              selectedYear = year
            }.tag(year)
          }
        }
      }
      .padding()
      
      Divider()
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
      
      HStack {
        Button("Cancel") {
          onDismiss()
        }
        .keyboardShortcut(.cancelAction)
        .largeButton()
        
        Spacer()
        
        Button("Save...") {
          sharedSettings.cutOffYear = selectedYear
          if Int(selectedYear) ?? 0 < Int(initialYear) ?? 0 {
            onSave(true)
          } else {
            onSave(false)
          }
        }
        .keyboardShortcut(.defaultAction)
        .largeButton(foregroundColor: .white, backgroundColor: .accentColor, pressedColor: .accentColor.opacity(0.6))
      }
      .padding()
    }
    .padding()
    .frame(minWidth: 400)
    .onAppear {
      selectedYear = sharedSettings.cutOffYear
      initialYear = sharedSettings.cutOffYear
    }
  }
  
  init(sharedSettings: SharedSettings, onDismiss: @escaping () -> Void, onSave: @escaping (Bool) -> Void) {
    self.sharedSettings = sharedSettings
    self.onDismiss = onDismiss
    self.onSave = onSave
    self._selectedYear = State(initialValue: sharedSettings.cutOffYear)
    self._initialYear = State(initialValue: sharedSettings.cutOffYear)
  }
}

//struct SettingsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SettingsView()
//  }
//}
