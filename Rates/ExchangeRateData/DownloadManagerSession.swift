//
//  DownloadManagerSession.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

class DownloadManagerSession {
  func getExchangeRateData(fromUrlString: String = Settings.defaultExchangeRatesUrlString) async throws -> URL {
    let downloadManager = DownloadManager()
    
    guard let url = URL(string: fromUrlString) else {
      print("Invalid URL string")
      throw DownloadError.invalidURL
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      downloadManager.downloadFile(from: url) { (localURL, error) in
        if let error = error {
          print("Download failed: \(error.localizedDescription)")
          continuation.resume(throwing: error)
        } else if let localURL = localURL {
          // Access the downloaded file at localURL
          print("File downloaded successfully. Local URL: \(localURL)")
          
          let fileExtension = localURL.pathExtension.lowercased()
          
          if fileExtension == "csv" {
            continuation.resume(returning: localURL)
          } else if fileExtension == "zip" {
            let destinationURL = localURL.deletingPathExtension()
            do {
              try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
              try FileManager.default.unzipItem(at: localURL, to: destinationURL)
              
              if let csvURL = self.recursivelyFindCSVFile(in: destinationURL) {
                continuation.resume(returning: csvURL)
              } else {
                let error = DownloadError.invalidFileFormat
                print("No CSV file found in the unzipped folder")
                continuation.resume(throwing: error)
              }
            } catch {
              print("Unzipping failed: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          } else {
            let error = DownloadError.invalidFileFormat
            print("Invalid file format: \(fileExtension)")
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }
  
  private func recursivelyFindCSVFile(in folderURL: URL) -> URL? {
    let fileManager = FileManager.default
    do {
      let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
      for itemURL in contents {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDirectory) {
          if isDirectory.boolValue {
            if let csvURL = recursivelyFindCSVFile(in: itemURL) {
              return csvURL
            }
          } else if itemURL.pathExtension.lowercased() == "csv" {
            return itemURL
          }
        }
      }
    } catch {
      print("Error while searching for CSV file: \(error.localizedDescription)")
    }
    
    return nil
  }
  
  enum DownloadError: Error {
    case invalidURL
    case invalidFileFormat
  }
}
