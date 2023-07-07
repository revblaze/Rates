//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

class ViewController: NSViewController {
  
  var downloadedFileUrl: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear() {
    
    beginDataDownloadSession()
  }
  
  func beginDataDownloadSession() {
    let session = DownloadManagerSession()
    
    //if let session.getExchangeRateData(fromUrlString: Settings.defaultExchangeRatesUrlString)
  }
  
  
  
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

