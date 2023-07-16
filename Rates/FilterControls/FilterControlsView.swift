//
//  FilterControlsView.swift
//  Rates
//
//  Created by Justin Bush on 7/16/23.
//

import SwiftUI

struct FilterControlsView: View {
  @State private var condition: String = ""
  @State private var filters: [String] = []
  
  var body: some View {
    VStack {
      HStack {
        Text("Condition")
        Spacer()
        Dropdown(condition: $condition)
      }
      .padding()
      
      HStack {
        Button("Clear") {
          condition = ""
        }
        Spacer()
        Button("Add Filter") {
          filters.append(condition)
          condition = ""
        }
      }
      .padding(.horizontal)
      
      ScrollView {
        VStack {
          ForEach(filters, id: \.self) { filter in
            Text(filter)
              .padding()
          }
        }
      }
      .background(Color.gray.opacity(0.1))
    }
  }
}

struct Dropdown: View {
  @Binding var condition: String
  
  var body: some View {
    // Implement your dropdown logic here
    Text("Dropdown")
  }
}

struct FilterControlsView_Previews: PreviewProvider {
  static var previews: some View {
    FilterControlsView()
  }
}
