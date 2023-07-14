//
//  Constants.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

struct Constants {
  
  /// The URL string for the CSV file to be downloaded.
    static let csvUrlString = "https://www.bis.org/statistics/full_xru_d_csv_row.zip"
    /// The default date used in some calculations.
    static let defaultDate = DateComponents(year: 2016, month: 1, day: 1).date!
    
    // MARK: Utility Constants
    /// A string containing alphanumeric characters used for generating random strings.
    static let alphaNumericString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    /// The name of the main storyboard in the project.
    static let mainStoryboard = "Main"
    /// The identifier for the ImportFileTemplateViewController.
    static let importFileTemplateViewControllerIdentifier = "ImportFileTemplateViewController"
  
}
