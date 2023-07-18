
//
//  DownloadManager.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation
import ZIPFoundation

/// A class with methods for downloading a file from a URL, removing all files in the document directory, and unzipping a file.
class DownloadManager {
  
  /// Downloads a file from a URL.
  ///
  /// - Parameters:
  ///   - url: The URL to download the file from.
  ///   - completion: The completion handler to call when the download is complete. This handler is passed the URL of the downloaded file, or `nil` if an error occurs.
  func downloadFile(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
    let task = URLSession.shared.downloadTask(with: url) { (temporaryURL, response, error) in
      if let error = error {
        completion(nil, error)
        return
      }
      
      guard let temporaryURL = temporaryURL else {
        completion(nil, NSError(domain: "com.example", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create temporary file URL."]))
        return
      }
      
      let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let destinationURL = documentDirectoryURL.appendingPathComponent(url.lastPathComponent)
      
      do {
        try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)
        completion(destinationURL, nil)
      } catch {
        completion(nil, error)
      }
    }
    
    task.resume()
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
      
      Debug.log("[removeAllFilesInDocumentDirectory] All files in the document directory removed successfully.")
    } catch {
      Debug.log("[removeAllFilesInDocumentDirectory] Failed to remove files in the document directory: \(error.localizedDescription)")
    }
  }
  
  /// Unzips a file at a specified path to a destination path.
  ///
  /// - Parameters:
  ///   - zipPath: The path of the zip file to unzip.
  ///   - destinationPath: The destination path to unzip the file to.
  /// - Throws: An error if the zip file is not found or the unzipping process fails.
  func unzipFile(atPath zipPath: String, toDestination destinationPath: String) throws {
    let fileManager = FileManager.default
    
    guard fileManager.fileExists(atPath: zipPath) else {
      throw NSError(domain: "com.example", code: 404, userInfo: [NSLocalizedDescriptionKey: "Zip file not found"])
    }
    
    let destinationUrl = URL(fileURLWithPath: destinationPath)
    
    do {
      try fileManager.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
      
      try fileManager.unzipItem(at: URL(fileURLWithPath: zipPath), to: destinationUrl)
      
      Debug.log("File unzipped successfully.")
    } catch {
      throw error
    }
  }
  
}
