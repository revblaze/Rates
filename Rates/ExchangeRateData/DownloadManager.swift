//
//  DownloadManager.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Foundation
import ZIPFoundation

class DownloadManager {
  
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
  
  
  func removeAllFilesInDocumentDirectory() {
    let fileManager = FileManager.default
    let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    do {
      let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: [])
      
      for fileURL in fileURLs {
        try fileManager.removeItem(at: fileURL)
      }
      
      print("All files in the document directory removed successfully.")
    } catch {
      print("Failed to remove files in the document directory: \(error.localizedDescription)")
    }
  }
  
  func unzipFile(atPath zipPath: String, toDestination destinationPath: String) throws {
      let fileManager = FileManager.default
      
      guard fileManager.fileExists(atPath: zipPath) else {
          throw NSError(domain: "com.example", code: 404, userInfo: [NSLocalizedDescriptionKey: "Zip file not found"])
      }
      
      let destinationURL = URL(fileURLWithPath: destinationPath)
      
      do {
          try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
          
          try fileManager.unzipItem(at: URL(fileURLWithPath: zipPath), to: destinationURL)
          
          print("File unzipped successfully.")
      } catch {
          throw error
      }
  }
  
}
