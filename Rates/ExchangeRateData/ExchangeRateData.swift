//
//  ExchangeRateData.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

class ExchangeRateData {
  
  func getDb(fromUrl: String, withCutOffDate: String = "2016-01-01") async -> URL? {
    return await withTaskGroup(of: URL?.self) { group in
      group.addTask {
        do {
          let downloadManager = DownloadManager()
          downloadManager.removeAllFilesInDocumentDirectory()
          
          let session = DownloadManagerSession()
          let fileURL = try await session.getExchangeRateData(fromUrlString: fromUrl)
          Debug.log("Downloaded file URL: \(fileURL)")
          
          let parseCsv = ParseCSV()
          try parseCsv.clean(at: fileURL)
          Debug.log("Lines deleted successfully.")
          
          parseCsv.removeDuplicateColumns(fileURL: fileURL)
          
          let convertCsv = ConvertCSV()
          if let sqliteFileURL = convertCsv.toSQLite(fileURL: fileURL) {
            Debug.log("SQLite file URL: \(sqliteFileURL)")
            return sqliteFileURL
          } else {
            Debug.log("Conversion failed.")
          }
        } catch {
          Debug.log("Error: \(error)")
        }
        
        return nil
      }
      
      // Wait for all tasks to complete
      for await result in group {
        if let sqliteFileURL = result {
          return sqliteFileURL
        }
      }
      
      return nil
    }
  }
  
}
