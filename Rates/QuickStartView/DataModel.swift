//
//  DataModel.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import Foundation

class DataModel: ObservableObject {
  @Published var sections: [SectionData] = []
  
  init(filename: String) {
    load(from: filename)
  }
  
  private func load(from filename: String) {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
      return
    }
    
    let decoder = JSONDecoder()
    sections = (try? decoder.decode([SectionData].self, from: data)) ?? []
  }
}
