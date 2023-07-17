//
//  DataSelectionView.swift
//  Rates
//
//  Created by Justin Bush on 7/17/23.
//

import SwiftUI

struct DataSelectionView: View {
  @ObservedObject var sharedHeaders: SharedHeaders
  @State private var selectedDate: String?
  @State private var selectedAmount: String?
  @State private var selectedCurrency: String?
  @State private var amountCurrencyCombined: Bool = false
  @State private var showError: Bool = false
  @State private var isConvertButtonPressed: Bool = false
  
  var body: some View {
    VStack {
      Text("Select the transaction data to be used for the currency conversion")
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 6)
        .padding(.bottom, 10)
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
      }
      Divider()
        .padding(.vertical, 6)
      HStack {
        Text("Convert to Currency")
        Menu {
          ForEach(sharedHeaders.availableHeaders, id: \.self) { header in
            Button(header) {}
          }
        } label: {
          Text("Select")
        }
      }
      Divider()
        .padding(.vertical, 6)
      HStack {
        Button("Cancel") {
          print("Cancel")
        }
        Button("Convert") {
          isConvertButtonPressed = true
          checkForErrors()
          print("[Convert] Dates: \(selectedDate ?? ""), Amounts: \(selectedAmount ?? ""), Currencies: \(selectedCurrency ?? ""), AmountCurrencyCombined: \(amountCurrencyCombined).")
        }
      }
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
  }
  
  func checkForErrors() {
    showError = selectedDate == nil || selectedAmount == nil || (!amountCurrencyCombined && selectedCurrency == nil)
  }
}

//struct DataSelectionView_Previews: PreviewProvider {
//  static var previews: some View {
//    DataSelectionView()
//  }
//}
