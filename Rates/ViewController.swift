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
    beginLaunchSession()
  }
  
  func beginLaunchSession() {
    
    if dataNeedsUpdating() {
      // TODO: IF NO INTERNET CONNECTION:
      // Display 'outdated' warning
      
      // TODO: Start download/loading animation
      Task.detached {
        let exchangeRateData = ExchangeRateData()
        if let dbFileUrl = await exchangeRateData.getDb(fromUrl: Settings.defaultExchangeRatesUrlString) {
          Debug.log("Db file obtained: \(dbFileUrl)")
          // TODO: Update UI?
          
        } else {
          Debug.log("Error occured while awaiting getDb()")
          // TODO: Present error
        }
      }
      // TODO: Stop animations
    }
    
  }
  
  func dataNeedsUpdating() -> Bool {
    if DailyCheck.shouldPerformAction() {
      Debug.log("[DailyCheck] New Day: download new exchange rate data")
      return true
    } else {
      Debug.log("[DailyCheck] Same Day: no action required")
      return false
    }
  }
  
  
  
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

