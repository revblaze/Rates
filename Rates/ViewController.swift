//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

class ViewController: NSViewController {
  weak var delegate: FileSelectionDelegate?
  
  var csvTableView: CSVTableView!
  private var scrollView: NSScrollView!
  
  var statusBarState: StatusBarState? = .loading
  @IBOutlet weak var statusBarButton: NSButton!
  @IBOutlet weak var statusBarText: NSTextField!
  @IBOutlet weak var statusBarProgressBar: NSProgressIndicator!
  @IBOutlet weak var statusBarRefreshButton: NSButton!
  var statusBarButtonIsPulsing = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    initCsvTableScrollView()
  }
  
  override func viewDidAppear() {
    beginLaunchSession()
  }
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
  func initCsvTableScrollView() {
    scrollView = NSScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.width, .height]
    scrollView.hasVerticalScroller = true
    
    let bottomOffset: CGFloat = 30.0
    let scrollViewHeight = view.bounds.height - bottomOffset
    let scrollViewOriginY = bottomOffset
    scrollView.frame = CGRect(x: 0, y: scrollViewOriginY, width: view.bounds.width, height: scrollViewHeight)
    
    csvTableView = CSVTableView(frame: scrollView.bounds)
    csvTableView.autoresizingMask = [.width, .height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: nil)
  }
}
