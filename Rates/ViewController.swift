//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa

/// Protocol to notify other parts of the application when a file is selected in this view controller.
protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

/// The main view controller for the application.
class ViewController: NSViewController {
  weak var delegate: FileSelectionDelegate?
  
  /// A table view for displaying CSV data.
  var csvTableView: CSVTableView!
  /// A scroll view for scrolling the `csvTableView`.
  private var scrollView: NSScrollView!
  
  /// Properties related to managing the status bar in the application.
  var statusBarState: StatusBarState? = .loading
  @IBOutlet weak var statusBarButton: NSButton!
  @IBOutlet weak var statusBarText: NSTextField!
  @IBOutlet weak var statusBarProgressBar: NSProgressIndicator!
  @IBOutlet weak var statusBarRefreshButton: NSButton!
  var statusBarButtonIsPulsing = false
  
  /// Called after the view controller's view is loaded into memory.
  ///
  /// Initializes the CSV table scroll view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCsvTableScrollView()
  }
  
  /// Called after the view controller's view is added to a view hierarchy.
  ///
  /// Begins the launch session.
  override func viewDidAppear() {
    beginLaunchSession()
  }
  
  /// A placeholder for the data that the view controller manages.
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  /// Initializes a scroll view for the CSV table view.
  func initCsvTableScrollView() {
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    
    csvTableView = CSVTableView()
    csvTableView.autoresizingMask = [.height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView)
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    
    let bottomOffset: CGFloat = 30.0
    let scrollViewHeight = view.bounds.height - bottomOffset
    let scrollViewOriginY = bottomOffset
    scrollView.frame = CGRect(x: 0, y: scrollViewOriginY, width: view.bounds.width, height: scrollViewHeight)
    
    csvTableView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
  }
}
