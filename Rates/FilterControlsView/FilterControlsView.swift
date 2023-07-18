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
  
  // ViewController functions
  var selectCustomHeaderForTableView: () -> Void
  var revertTableViewChanges: () -> Void
  var filterTableViewColumnHeaders: ([String], FilterTableViewInclusionExclusion) -> Void
  
  var body: some View {
    ZStack {
      //      BackgroundBlurView(material: .sidebar, blendingMode: .behindWindow) // Use the desired material and blending mode
      //        .edgesIgnoringSafeArea(.all)
      VStack {
        Button(action: {
          self.selectCustomHeaderForTableView()
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
            if !filters.contains(where: { $0.isEmpty }) {
              filters.append("")
            }
          }) {
            Text("Add Filter")
          }
        }
        .padding(.horizontal)
        
        Divider()
          .padding(.horizontal)
          .padding(.top)
          .padding(.bottom, -8)
        
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
            .padding(.horizontal)
            .padding(.vertical, 6)
          }
          .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
        //.background(Color.gray.opacity(0.1))
        
        Spacer()
        
        Divider()
          .padding(.horizontal)
          .padding(.top, -8)
        
        HStack {
          Button(action: {
            self.revertTableViewChanges()
          }) {
            Text("Clear Filters")
          }
          Spacer()
          Button(action: {
            self.filterTableViewColumnHeaders(self.columnHeadersToFilter, self.selectedFilterType)
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
}

//struct FilterControlsView_Previews: PreviewProvider {
//  static var previews: some View {
//    let sharedHeaders = SharedHeaders()
//    FilterControlsView(sharedHeaders: sharedHeaders)
//  }
//}
