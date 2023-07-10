//
//  FileTemplateParsing.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

struct FileTemplateParsing {
  
  static func detectFileTemplateType(fileUrl: URL) -> FileTemplates {
    
    if containsAppStoreConnectHeaders(fileUrl: fileUrl) {
      return .appStoreConnectSales
    } else {
      return .generic
    }
    
  }
  
  static func containsAppStoreConnectHeaders(fileUrl: URL) -> Bool {
    do {
      let fileContents = try String(contentsOf: fileUrl)
      
      // Split the file contents into an array of lines
      let lines = fileContents.components(separatedBy: .newlines)
      
      // Check if the first line contains the expected headers
      if let firstLine = lines.first {
        if firstLine.contains("Vendor Name") {
          return true
        } else if firstLine.contains("Start Date"),
                  firstLine.contains("End Date"),
                  firstLine.contains("UPC") {
          Debug.log("Wrong App Store Connect sales file format. Please choose Create Report > All Countries and Regions detailed. Then import that TXT file.")
          
          // TODO: Stop conversion with error
          
          return true
        }
      }
    } catch {
      print("Error reading file: \(error)")
    }
    
    return false
  }
  
  
  // MARK: Parse App Store Connect Sales
  static func cleanAppStoreFile(fileUrl: URL) -> URL? {
    guard let fileContent = try? String(contentsOf: fileUrl) else {
      return nil
    }
    
    var cleanedContent = ""
    
    fileContent.enumerateLines { (line, stop) in
      let firstCharacter = line.first
      
      if line.hasPrefix("Transaction Date") || firstCharacter?.isNumber == true || firstCharacter == " " || firstCharacter == "\t" {
        cleanedContent += line + "\n"
      }
    }
    
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let randomCharacters = randomString(length: 5)
    let cleanedFileName = "appstoresales_\(randomCharacters).txt"
    let cleanedFileUrl = documentsDirectory.appendingPathComponent(cleanedFileName)
    
    do {
      try cleanedContent.write(to: cleanedFileUrl, atomically: true, encoding: .utf8)
      return cleanedFileUrl
    } catch {
      print("Failed to write cleaned content to file: \(error)")
      return nil
    }
  }
  
  static func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
}