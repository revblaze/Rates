//
//  Codable+QuickStartView.swift
//  Rates
//
//  Created by Justin Bush on 7/29/23.
//

import Foundation

struct SectionData: Codable {
  let title: String
  let content: [StepImageCaptionRowData]
  let expanded: Bool?
}

struct StepImageCaptionRowData: Codable {
  let header: String
  let imageString: String?
  let caption: String?
  let imgWidth: CGFloat?
  let imgHeight: CGFloat?
}

extension QuickStartView {
  func loadSectionData(from file: String) -> [SectionData]? {
    guard let url = Bundle.main.url(forResource: file, withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
      return nil
    }
    
    let decoder = JSONDecoder()
    return try? decoder.decode([SectionData].self, from: data)
  }
}
