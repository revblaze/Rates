//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa
import SwiftUI

let VIEW_WIDTH: CGFloat = 260
let STATUS_BAR_HEIGHT: CGFloat = 30

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

class ViewController: NSViewController {
  weak var delegate: FileSelectionDelegate?
  
  var csvTableView: CSVTableView!
  private var scrollView: NSScrollView!
  
  var statusBarState: StatusBarState? = .loading
  @IBOutlet weak var statusBarViewContainer: NSView!
  @IBOutlet weak var statusBarButton: NSButton!
  @IBOutlet weak var statusBarText: NSTextField!
  @IBOutlet weak var statusBarProgressBar: NSProgressIndicator!
  @IBOutlet weak var statusBarRefreshButton: NSButton!
  var statusBarButtonIsPulsing = false
  
  var filterControlsView: NSHostingView<FilterControlsView>!
  var filterControlsConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCsvTableScrollView()
    initFilterControlsView()
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
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    
    csvTableView = CSVTableView()
    csvTableView.autoresizingMask = [.height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: filterControlsView)
  }
  
  func initFilterControlsView() {
    filterControlsView = NSHostingView(rootView: FilterControlsView())
    filterControlsView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(filterControlsView)
    
    filterControlsConstraint = filterControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: VIEW_WIDTH)
    filterControlsConstraint.isActive = true
    
    NSLayoutConstraint.activate([
      filterControlsView.topAnchor.constraint(equalTo: view.topAnchor),
      filterControlsView.bottomAnchor.constraint(equalTo: statusBarViewContainer.topAnchor),
      filterControlsView.widthAnchor.constraint(equalToConstant: VIEW_WIDTH),
    ])
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    
    let bottomOffset: CGFloat = STATUS_BAR_HEIGHT
    let scrollViewHeight = view.bounds.height - bottomOffset
    let scrollViewOriginY = bottomOffset
    scrollView.frame = CGRect(x: 0, y: scrollViewOriginY, width: view.bounds.width - (filterControlsConstraint.constant == 0 ? VIEW_WIDTH : 0), height: scrollViewHeight)
    
    csvTableView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by VIEW_WIDTH such that is visible on the screen.
   */
  func slideInFilterControlsView() {
    filterControlsConstraint.constant = 0
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by VIEW_WIDTH such that it is once again out of view entirely.
   */
  func slideOutFilterControlsView() {
    filterControlsConstraint.constant = VIEW_WIDTH
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }
  }
  
  func filterTableViewColumnHeaders(_ columnHeaders: [String], withFilterType: FilterTableViewInclusionExclusion) {
    if withFilterType == .filterTableViewToOnlyShowColumnsWithHeaders {
      csvTableView.filterTableViewToOnlyShowColumnsWithHeaders(columnHeaders)
    } else {
      csvTableView.filterTableViewToOnlyHideColumnsWithHeaders(columnHeaders)
    }
  }
}
