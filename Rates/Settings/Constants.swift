//
//  Constants.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

struct Constants {
  
  // MARK: SQLite Database Constants
  /// The URL string for the CSV file to be downloaded.
  static let csvUrlString = "https://www.bis.org/statistics/full_xru_d_csv_row.zip"
  /// The SQLite database `table_name` to query.
  static let sqliteTableName = "data"
  /// The SQLite database file name.
  static let sqliteFileName = "data.db"
  /// Title of the SQLite date column. Replaces "Currency".
  static let sqliteDateColumnValue = "Date"
  /// The default date used in some calculations.
  static let defaultDate = DateComponents(year: 2016, month: 1, day: 1).date!
  // MARK: Launch Data Presets
  /// The value used to replace "NaN" values in the launch screen data.
  static let replaceNanLinesInLaunchData = "––"
  /// The value used to replace empty values in the launch screen data.
  static let replaceEmptyLinesInLaunchData = "––"
  
  
  // MARK: - UI Properties
  /// The name of the main storyboard in the project.
  static let mainStoryboard = "Main"
  /// The identifier for the ImportFileTemplateViewController.
  static let importFileTemplateViewControllerIdentifier = "ImportFileTemplateViewController"
  /// Width of the FilterControlsView sheet presentation.
  static let filterControlsViewWidth: CGFloat = 260
  /// Height of the ViewController Status Bar.
  static let statusBarHeight: CGFloat = 30
  /// Identifier of the DataSelectionView's Hosting Controller.
  static let dataSelectionViewHostingControllerIdentifier = "DataSelectionViewHostingController"
  /// Identifier of the SaveFileView's Hosting Controller.
  static let saveFileViewHostingControllerIdentifier = "SaveFileViewHostingController"
  
  
  // MARK: - Utility Constants
  /// A string containing alphanumeric characters used for generating random strings.
  static let alphaNumericString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
}
