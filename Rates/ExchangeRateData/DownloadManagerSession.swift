//
//  DownloadManagerSession.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

class DownloadManagerSession {
  func getExchangeRateData(fromUrlString: String = Settings.defaultExchangeRatesUrlString) -> Result<URL, Error> {
    let downloadManager = DownloadManager()
    
    guard let url = URL(string: fromUrlString) else {
      print("Invalid URL string")
      return .failure(DownloadError.invalidURL)
    }
    
    var result: Result<URL, Error>?
    
    downloadManager.downloadFile(from: url) { (localURL, error) in
      if let error = error {
        print("Download failed: \(error.localizedDescription)")
        result = .failure(error)
      } else if let localURL = localURL {
        // Access the downloaded file at localURL
        print("File downloaded successfully. Local URL: \(localURL)")
        
        let fileExtension = localURL.pathExtension.lowercased()
        
        if fileExtension == "csv" {
          result = .success(localURL)
        } else if fileExtension == "zip" {
          let destinationURL = localURL.deletingPathExtension()
          do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.unzipItem(at: localURL, to: destinationURL)
            result = .success(destinationURL)
          } catch {
            print("Unzipping failed: \(error.localizedDescription)")
            result = .failure(error)
          }
        } else {
          let error = DownloadError.invalidFileFormat
          print("Invalid file format: \(fileExtension)")
          result = .failure(error)
        }
      }
    }
    
    // Wait until the download completion block is executed
    while result == nil {
      RunLoop.current.run(mode: .default, before: .distantFuture)
    }
    
    return result!
  }
  
  enum DownloadError: Error {
    case invalidURL
    case invalidFileFormat
  }
}


