
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
      Debug.log("[DownloadManagerSession.getExchangeRateData] Invalid URL string")
      throw DownloadError.invalidUrl
    }
    
    do {
      return try await downloadExchangeRateData(downloadManager: downloadManager, url: url)
    } catch {
      Debug.log("[DownloadManagerSession.getExchangeRateData] Download failed: \(error.localizedDescription)")
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
      downloadManager.downloadFile(from: url) { (localUrl, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let localUrl = localUrl {
          Debug.log("[DownloadManagerSession.downloadExchangeRateData] File downloaded successfully. Local URL: \(localUrl)")
          
          let fileExtension = localUrl.pathExtension.lowercased()
          
          if fileExtension == "csv" {
            continuation.resume(returning: localUrl)
          } else if fileExtension == "zip" {
            let destinationUrl = localUrl.deletingPathExtension()
            do {
              try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
              try FileManager.default.unzipItem(at: localUrl, to: destinationUrl)
              
              if let csvUrl = self.recursivelyFindCSVFile(in: destinationUrl) {
                continuation.resume(returning: csvUrl)
              } else {
                let error = DownloadError.invalidFileFormat
                Debug.log("[DownloadManagerSession.downloadExchangeRateData] No CSV file found in the unzipped folder")
                continuation.resume(throwing: error)
              }
            } catch {
              Debug.log("[DownloadManagerSession.downloadExchangeRateData] Unzipping failed: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          } else {
            let error = DownloadError.invalidFileFormat
            Debug.log("[DownloadManagerSession.downloadExchangeRateData] Invalid file format: \(fileExtension)")
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }
  
  /// Recursively finds a CSV file in a folder.
  ///
  /// - Parameter folderUrl: The URL of the folder to search in.
  /// - Returns: The URL of the CSV file if found, or `nil` otherwise.
  private func recursivelyFindCSVFile(in folderUrl: URL) -> URL? {
    let fileManager = FileManager.default
    do {
      let contents = try fileManager.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
      for itemUrl in contents {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: itemUrl.path, isDirectory: &isDirectory) {
          if isDirectory.boolValue {
            if let csvUrl = recursivelyFindCSVFile(in: itemUrl) {
              return csvUrl
            }
          } else if itemUrl.pathExtension.lowercased() == FileExtensions.csv.rawValue  {//"csv" {
            return itemUrl
          }
        }
      }
    } catch {
      Debug.log("[DownloadManagerSession.recursivelyFindCSVFile] Error while searching for CSV file: \(error.localizedDescription)")
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
      
      Debug.log("[DownloadManagerSession.removeAllFilesInDocumentDirectory] All files in the document directory removed successfully.")
    } catch {
      Debug.log("[DownloadManagerSession.removeAllFilesInDocumentDirectory] Failed to remove files in the document directory: \(error.localizedDescription)")
    }
  }
  
  /// An enumeration that defines two types of download errors: `invalidUrl` and `invalidFileFormat`.
  enum DownloadError: Error {
    case invalidUrl
    case invalidFileFormat
  }
}
