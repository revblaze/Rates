//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

class ViewController: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear() {
    

    Task.detached {
      await self.beginLaunchSession()
    }
  }
  
  func beginLaunchSession() async {
    
    // if it has been >7 since last download or is Thursday; then, reset flag
    let exchangeRateData = ExchangeRateData()
    let dbFileUrl = await exchangeRateData.getDb(fromUrl: Settings.defaultExchangeRatesUrlString)
    
    print("Db file obtained: \(dbFileUrl)")
    
  }
  
  
  
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

