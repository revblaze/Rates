
//
//  ExchangeRateData.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

/// A class with an asynchronous method for getting a database from a URL.
class ExchangeRateData {
  
  /// Gets a database from a URL.
  ///
  /// - Parameters:
  ///   - fromUrl: The URL to get the database from.
  ///   - withCutOffDate: The cut-off date for the data to be retrieved. The default value is "2016-01-01".
  /// - Returns: The URL of the SQLite file containing the database, or `nil` if an error occurs during the process.
  func getDb(fromUrl: String, withCutOffDate: String = "2016-01-01") async -> URL? {
    return await withTaskGroup(of: URL?.self) { group in
      group.addTask {
        do {
          let downloadManager = DownloadManager()
          downloadManager.removeAllFilesInDocumentDirectory()
          
          let session = DownloadManagerSession()
          let fileUrl = try await session.getExchangeRateData(fromUrlString: fromUrl)
          Debug.log("Downloaded file URL: \(fileUrl)")
          
          let parseCsv = ParseCSV()
          try parseCsv.clean(at: fileUrl)
          Debug.log("Lines deleted successfully.")
          
          parseCsv.removeDuplicateColumns(fileUrl: fileUrl)
          
          let convertCsv = ConvertCSV()
          if let sqliteFileUrl = convertCsv.toSQLite(fileUrl: fileUrl) {
            Debug.log("SQLite file URL: \(sqliteFileUrl)")
            return sqliteFileUrl
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
