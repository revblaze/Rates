//
//  FilterControlsView.swift
//  Rates
//
//  Created by Justin Bush on 7/16/23.
//

import SwiftUI

enum FilterTableViewInclusionExclusion: String, CaseIterable {
  case filterTableViewToOnlyShowColumnsWithHeaders = "Show Headers"
  case filterTableViewToOnlyHideColumnsWithHeaders = "Hide Headers"
}

struct FilterControlsView: View {
  @State var condition: String = ""
  @State var filters: [String] = []
  @State var columnHeadersToFilter: [String] = []
  @State var selectedFilterType: FilterTableViewInclusionExclusion = .filterTableViewToOnlyShowColumnsWithHeaders
  
  // Observe the sharedHeaders instance.
  @ObservedObject var sharedHeaders: SharedHeaders
  
  var body: some View {
    VStack {
      Button(action: {
        // ViewController's selectCustomHeaderForTableView() function
      }) {
        Text("Manually Select Header Row")
      }
      
      HStack {
        Text("Condition")
        Spacer()
        Menu {
          ForEach(FilterTableViewInclusionExclusion.allCases, id: \.self) { filterType in
            Button(action: {
              self.selectedFilterType = filterType
            }) {
              Text(filterType.rawValue)
            }
          }
        } label: {
          Text(selectedFilterType.rawValue)
        }
      }
      .padding()
      
      HStack {
        Button(action: {
          filters.removeAll()
          columnHeadersToFilter.removeAll()
        }) {
          Text("Clear")
        }
        Spacer()
        Button(action: {
          filters.append(condition)
          condition = ""
        }) {
          Text("Add Filter")
        }
      }
      .padding(.horizontal)
      
      Divider()
        .padding(.vertical)
      
      ScrollView {
        ForEach(filters, id: \.self) { filter in
          HStack {
            Menu {
              ForEach(sharedHeaders.availableHeaders.filter { !filters.contains($0) }, id: \.self) { header in
                Button(action: {
                  columnHeadersToFilter.append(header)
                  filters.append(header)
                }) {
                  Text(header)
                }
              }
            } label: {
              Text(filter)
            }
            Spacer()
            Button(action: {
              filters.removeAll(where: { $0 == filter })
              columnHeadersToFilter.removeAll(where: { $0 == filter })
            }) {
              Text("Remove")
            }
          }
          .padding()
        }
      }
      .background(Color.gray.opacity(0.1))
      
      Spacer()
      
      Divider()
        //.padding(.vertical)
      
      HStack {
        Button(action: {
          // ViewController's revertTableViewChanges() function
        }) {
          Text("Undo Filters")
        }
        Spacer()
        Button(action: {
          // ViewController's filterTableViewColumnHeaders(_ columnHeaders: [String], withFilterType: FilterTableViewInclusionExclusion) function
        }) {
          Text("Apply Filters")
        }
      }
      .padding()
      
    }
    .padding(.top, 16)
    .padding(.bottom, 6)
  }
}

struct FilterControlsView_Previews: PreviewProvider {
  static var previews: some View {
    let sharedHeaders = SharedHeaders()
    FilterControlsView(sharedHeaders: sharedHeaders)
  }
}
