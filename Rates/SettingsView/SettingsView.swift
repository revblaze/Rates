//
//  SettingsView.swift
//  Rates
//
//  Created by Justin Bush on 7/23/23.
//

import SwiftUI

class SharedSettings: ObservableObject {
  
  @Published var showExchangeRateDataOnLaunch = false
  
  @Published var cutOffYear: String {
    didSet { UserDefaults.standard.set(cutOffYear, forKey: "cutOffYearDefaultsKey") }
  }
  @Published var dontShowIntroViewOnLaunch: Bool {
    didSet { UserDefaults.standard.set(dontShowIntroViewOnLaunch, forKey: "dontShowIntroViewOnLaunchDefaultsKey") }
  }
  
  init() {
    self.cutOffYear = UserDefaults.standard.string(forKey: "cutOffYearDefaultsKey") ?? Constants.defaultCutOffYearString
    self.dontShowIntroViewOnLaunch = UserDefaults.standard.bool(forKey: "dontShowIntroViewOnLaunchDefaultsKey")
  }
}

struct SettingsView: View {
  @ObservedObject var sharedSettings: SharedSettings
  var onDismiss: () -> Void
  var onSave: (String) -> Void
  
  @State private var selectedYear: String
  @State private var initialYear: String
  
  init(sharedSettings: SharedSettings, onDismiss: @escaping () -> Void, onSave: @escaping (String) -> Void) {
    self.sharedSettings = sharedSettings
    self.onDismiss = onDismiss
    self.onSave = onSave
    self._selectedYear = State(initialValue: sharedSettings.cutOffYear)
    self._initialYear = State(initialValue: sharedSettings.cutOffYear)
  }
  
  var body: some View {
    let years = Array((1950...Calendar.current.component(.year, from: Date())).map { String($0) }.reversed())
    
    VStack {
      HStack {
        Text("Settings")
          .font(.largeTitle)
      }
      .padding()
      
      CustomYearRangeMenuSettingRow(
        header: "Historical Exchange Rate Data",
        label: "",
        menuItems: years,
        selectedItem: $selectedYear,
        popoverButton: PopoverButton(header: "Exchange Rate Data in Years", label: "The range of exchange rate data to use.\nFrom the selected year, to present day.\n\nie. January 1, \(selectedYear) – Present Day", width: 320, height: 160)
      )
      
      Divider()
        .padding(.vertical, 6)
      
      HStack {
        Button("Cancel") {
          onDismiss()
        }
        .keyboardShortcut(.cancelAction)
        .largeButton()
        
        Spacer()
        
        Button("Save") {
          onSave(selectedYear)
        }
        .keyboardShortcut(.defaultAction)
        .largeButton(foregroundColor: .white, backgroundColor: .accentColor, pressedColor: .accentColor.opacity(0.6))
      }
      .padding(.vertical, 6)
    }
    .padding()
    .padding(.horizontal, 12)
    .frame(minWidth: 400)
    .onAppear {
      selectedYear = sharedSettings.cutOffYear
      initialYear = sharedSettings.cutOffYear
    }
  }
}


/// smallLabel: "Please note that the further back you go, the larger the database will grow, and the slower it may become to retrieve conversion values. For this reason, it is recommended that you only select the dates that you're expecting to work with. You can always come back and change this value as needed."
struct MenuSettingRow: View {
  var header: String
  var label: String
  var menuItems: [String]
  @Binding var selectedItem: String
  var popoverButton: PopoverButton?
  
  var body: some View {
    Divider()
      .padding(.vertical, 6)
    
    HStack {
      VStack {
        HStack {
          Text(header)
            .font(.headline)
          Spacer()
        }
        
        HStack {
          Text(label)
          Menu(selectedItem) {
            ForEach(menuItems, id: \.self) { item in
              Button(item) {
                selectedItem = item
              }.tag(item)
            }
          }
        }
      }
      
      if let popoverButton = popoverButton {
        popoverButton
      }
    }
  }
}

struct CustomYearRangeMenuSettingRow: View {
  var header: String
  var label: String
  var menuItems: [String]
  @Binding var selectedItem: String
  var popoverButton: PopoverButton?
  
  var body: some View {
    Divider()
      .padding(.vertical, 6)
    
    HStack {
      VStack {
        HStack {
          Text(header)
            .font(.headline).underline()
          Spacer()
        }
        .padding(.vertical, 6)
        .padding(.bottom, 6)
        
        
        HStack {
          Text("From")
          Text("January 1,")
            .bold()
          Menu(selectedItem) {
            ForEach(menuItems, id: \.self) { item in
              Button(item) {
                selectedItem = item
              }.tag(item)
            }
          }
          Text(" to")
          Text("Present Day")
            .bold()
        }
        .padding(.bottom, 6)
      }
      
      if let popoverButton = popoverButton {
        popoverButton
          .padding(.vertical, 6)
      }
    }
  }
}

struct PopoverButton: View {
  var header: String?
  var label: String
  var smallLabel: String?
  var width: CGFloat
  var height: CGFloat
  
  @State private var isPopoverPresented = false
  
  var body: some View {
    VStack {
      Button(action: {
        isPopoverPresented.toggle()
      }) {
        Image(systemName: "questionmark.circle")
          .font(.system(size: 18))
          .foregroundColor(.secondary)
      }
      .buttonStyle(.plain)
      .popover(isPresented: $isPopoverPresented) {
        VStack {
          if let popoverHeader = header, !popoverHeader.isEmpty {
            Text(popoverHeader)
              .font(.headline)
              .padding(.top)
          }
          
          HStack {
            Text(label)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
              .padding()
           Spacer()
          }
          
          if let popoverSmallLabel = smallLabel, !popoverSmallLabel.isEmpty {
            HStack {
              Text(popoverSmallLabel)
                .font(.footnote)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.bottom)
              Spacer()
            }
          }
        
        }
        .padding()
        .frame(width: width, height: height)
      }
      
      Spacer()
    }
    .padding(.leading)
  }
}


//.fixedSize(horizontal: false, vertical: true)

//struct SettingsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SettingsView()
//  }
//}
