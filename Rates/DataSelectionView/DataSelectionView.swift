//
//  DataSelectionView.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import SwiftUI

struct DataSelectionView: View {
  @ObservedObject var sharedHeaders: SharedHeaders
  @ObservedObject var sharedFormattingOptions: SharedFormattingOptions
  @State private var selectedDate: String?
  @State private var selectedAmount: String?
  @State private var selectedCurrency: String?
  @State private var selectedConvertCurrency: String?
  @State private var amountCurrencyCombined: Bool = false
  @State private var showError: Bool = false
  @State private var isConvertButtonPressed: Bool = false
  var onDismiss: (() -> Void)?
  var onConvert: ((String, String, String, Bool, String) -> Void)?
  
  init(sharedHeaders: SharedHeaders, sharedFormattingOptions: SharedFormattingOptions, onDismiss: (() -> Void)?, onConvert: ((String, String, String, Bool, String) -> Void)?) {
    self.sharedHeaders = sharedHeaders
    self.sharedFormattingOptions = sharedFormattingOptions
    self.onDismiss = onDismiss
    self.onConvert = onConvert
    _selectedDate = State(initialValue: sharedHeaders.suggestedHeaders.count > 0 ? sharedHeaders.suggestedHeaders[0] : nil)
    _selectedAmount = State(initialValue: sharedHeaders.suggestedHeaders.count > 1 ? sharedHeaders.suggestedHeaders[1] : nil)
    _selectedCurrency = State(initialValue: sharedHeaders.suggestedHeaders.count > 2 ? sharedHeaders.suggestedHeaders[2] : nil)
    _selectedConvertCurrency = State(initialValue: sharedHeaders.availableCurrencyCodeHeaders.contains("USD") ? "USD" : nil)
  }
  
  var body: some View {
    VStack {
      Text("Select the columns to be used for currency conversion")
        .bold()
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 6)
        .padding(.bottom, 10)
      ColumnSelectionView(selectedDate: $selectedDate, selectedAmount: $selectedAmount, selectedCurrency: $selectedCurrency, amountCurrencyCombined: $amountCurrencyCombined, sharedHeaders: sharedHeaders)
      Divider()
        .padding(.vertical, 6)
      HStack {
        Text("Convert to Currency")
        Menu {
          ForEach(sharedHeaders.availableCurrencyCodeHeaders, id: \.self) { header in
            if header == "–––" {
              Divider()
              DividerItemView()
            } else {
              Button(header) {
                self.selectedConvertCurrency = header
              }
            }
          }
        } label: {
          Text(selectedConvertCurrency ?? "Select")
        }
      }
      Divider()
        .padding(.vertical, 6)
      
      FormattingOptionsView(sharedFormattingOptions: sharedFormattingOptions)
      
      Divider()
        .padding(.vertical, 6)
      HStack {
        Button("Cancel") {
          Debug.log("[DataSelectionView] User cancelled input.")
          onDismiss?()
        }
        .keyboardShortcut(.cancelAction)
        .largeButton()
        
        Spacer()
        
        Button("Convert") {
          isConvertButtonPressed = true
          checkForErrors()
          if !showError {
            Debug.log("[DataSelectionView] User clicked convert with Dates: \(selectedDate ?? ""), Amounts: \(selectedAmount ?? ""), Currencies: \(selectedCurrency ?? ""), AmountCurrencyCombined: \(amountCurrencyCombined), ConvertCurrency: \(selectedConvertCurrency ?? "").")
            onConvert?(selectedDate ?? "", selectedAmount ?? "", selectedCurrency ?? "", amountCurrencyCombined, selectedConvertCurrency ?? "")
          }
        }
        .keyboardShortcut(.defaultAction)
        .largeButton(foregroundColor: .white, backgroundColor: .accentColor, pressedColor: .accentColor.opacity(0.6))
      }
      .padding(.vertical, 6)
      
      if showError && isConvertButtonPressed {
        Text("Please select the columns of data to be used for the conversion.")
          .foregroundColor(.red)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding()
    .padding(.horizontal)
    .frame(minWidth: 380)
    .onChange(of: selectedDate) { _ in
      checkForErrors()
    }
    .onChange(of: selectedAmount) { _ in
      checkForErrors()
    }
    .onChange(of: selectedCurrency) { _ in
      checkForErrors()
    }
    .onChange(of: amountCurrencyCombined) { _ in
      checkForErrors()
    }
    .onAppear {
      if selectedCurrency == nil && selectedDate != nil && selectedAmount != nil {
        amountCurrencyCombined = true
      }
    }
  }
  
  func checkForErrors() {
    showError = selectedDate == nil || selectedAmount == nil || (!amountCurrencyCombined && selectedCurrency == nil)
  }
}

struct DividerItemView: View {
  var body: some View {
    Divider()
      .padding(.vertical, 4) // Adjust the padding as needed
      .foregroundColor(.gray) // Adjust the color as needed
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
      .onTapGesture {} // Empty action to prevent selection
  }
}

struct FormattingOptionsView: View {
  @ObservedObject var sharedFormattingOptions: SharedFormattingOptions
  @State private var isExpanded: Bool = false
  
  var body: some View {
    VStack {
      Button(action: {
        withAnimation {
          isExpanded.toggle()
        }
      }) {
        HStack {
          Text("Formatting Options")
            .bold()
          Spacer()
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
        }
      }
      .buttonStyle(PlainButtonStyle())
      .frame(maxWidth: .infinity)
      
      if isExpanded {
        VStack {
          HStack {
            Toggle(isOn: $sharedFormattingOptions.roundToTwoDecimalPlaces) {
              Text("Round to two decimal places")
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()  // Push the Toggle and Text to the left
          }
          .padding(.top, 10)
          HStack {
            Toggle(isOn: $sharedFormattingOptions.hideEmptyColumns) {
              Text("Remove empty columns")
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()  // Push the Toggle and Text to the left
          }
          HStack {
            Toggle(isOn: $sharedFormattingOptions.hideIrrelevantColumns) {
              Text("Remove irrelevant columns")
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()  // Push the Toggle and Text to the left
          }
        }
        .transition(.opacity)
      }
    }
  }
}

struct ColumnSelectionView: View {
  @Binding var selectedDate: String?
  @Binding var selectedAmount: String?
  @Binding var selectedCurrency: String?
  @Binding var amountCurrencyCombined: Bool
  @ObservedObject var sharedHeaders: SharedHeaders
  
  var body: some View {
    VStack {
      HStack {
        Text("Dates")
        Menu {
          ForEach(sharedHeaders.availableHeaders, id: \.self) { header in
            Button(header) {
              self.selectedDate = header
            }.disabled(selectedAmount == header || selectedCurrency == header)
          }
        } label: {
          Text(selectedDate ?? "Select")
        }
      }
      HStack {
        Text("Amounts")
        Menu {
          ForEach(sharedHeaders.availableHeaders, id: \.self) { header in
            Button(header) {
              self.selectedAmount = header
            }.disabled(selectedDate == header || selectedCurrency == header)
          }
        } label: {
          Text(selectedAmount ?? "Select")
        }
      }
      HStack {
        Text("Currencies")
        Menu {
          ForEach(sharedHeaders.availableHeaders, id: \.self) { header in
            Button(header) {
              self.selectedCurrency = header
            }.disabled(selectedDate == header || selectedAmount == header || amountCurrencyCombined)
          }
        } label: {
          Text(selectedCurrency ?? "Select")
        }.disabled(amountCurrencyCombined)
      }
      Toggle(isOn: $amountCurrencyCombined) {
        Text("Amounts and currencies are in the same column")
          .fixedSize(horizontal: false, vertical: true)
      }.onChange(of: amountCurrencyCombined) { newValue in
        if newValue {
          self.selectedCurrency = nil
        }
      }
    }
  }
}

//struct DataSelectionView_Previews: PreviewProvider {
//  static var previews: some View {
//    DataSelectionView()
//  }
//}
