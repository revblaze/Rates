
//
//  DownloadManagerSession.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation

/// A class with methods for getting exchange rate data from a URL, downloading exchange rate data, recursively finding a CSV file in a folder, and removing all files in the document directory.
class DownloadManagerSession {
  
  /// Gets exchange rate data from a URL.
  ///
  /// - Parameter fromUrlString: The URL string to get the exchange rate data from. The default value is `Settings.defaultExchangeRatesUrlString`.
  /// - Throws: An error of type `DownloadError` if the URL string is invalid or the file format is invalid.
  /// - Returns: The URL of the downloaded file.
  func getExchangeRateData(fromUrlString: String = Settings.defaultExchangeRatesUrlString) async throws -> URL {
    let downloadManager = DownloadManager()
    
    guard let url = URL(string: fromUrlString) else {
      Debug.log("Invalid URL string")
      throw DownloadError.invalidURL
    }
    
    do {
      return try await downloadExchangeRateData(downloadManager: downloadManager, url: url)
    } catch {
      Debug.log("Download failed: \(error.localizedDescription)")
      removeAllFilesInDocumentDirectory()
      return try await downloadExchangeRateData(downloadManager: downloadManager, url: url)
    }
  }
  
  /// Downloads exchange rate data.
  ///
  /// - Parameters:
  ///   - downloadManager: The `DownloadManager` instance to use for the download.
  ///   - url: The URL to download the file from.
  /// - Throws: An error if the download fails, the file format is invalid, or the file cannot be unzipped.
  /// - Returns: The URL of the downloaded file.
  private func downloadExchangeRateData(downloadManager: DownloadManager, url: URL) async throws -> URL {
    return try await withCheckedThrowingContinuation { continuation in
      downloadManager.downloadFile(from: url) { (localURL, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let localURL = localURL {
          Debug.log("File downloaded successfully. Local URL: \(localURL)")
          
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
                Debug.log("No CSV file found in the unzipped folder")
                continuation.resume(throwing: error)
              }
            } catch {
              Debug.log("Unzipping failed: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          } else {
            let error = DownloadError.invalidFileFormat
            Debug.log("Invalid file format: \(fileExtension)")
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }
  
  /// Recursively finds a CSV file in a folder.
  ///
  /// - Parameter folderURL: The URL of the folder to search in.
  /// - Returns: The URL of the CSV file if found, or `nil` otherwise.
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
      Debug.log("Error while searching for CSV file: \(error.localizedDescription)")
    }
    
    return nil
  }
  
  /// Removes all files in the document directory.
  func removeAllFilesInDocumentDirectory() {
    let fileManager = FileManager.default
    let documentDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    do {
      let fileUrls = try fileManager.contentsOfDirectory(at: documentDirectoryUrl, includingPropertiesForKeys: nil, options: [])
      
      for fileUrl in fileUrls {
        try fileManager.removeItem(at: fileUrl)
      }
      
      Debug.log("All files in the document directory removed successfully.")
    } catch {
      Debug.log("Failed to remove files in the document directory: \(error.localizedDescription)")
    }
  }
  
  /// An enumeration that defines two types of download errors: `invalidURL` and `invalidFileFormat`.
  enum DownloadError: Error {
    case invalidURL
    case invalidFileFormat
  }
}
