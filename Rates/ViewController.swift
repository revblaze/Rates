//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa
import SwiftUI

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

class ViewController: NSViewController {
  weak var delegate: FileSelectionDelegate?
  weak var windowController: WindowController?
  
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
  
  let sharedHeaders = SharedHeaders()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCsvTableScrollView()
    initFilterControlsView()
  }
  
  override func viewDidAppear() {
    beginLaunchSession()
  }
  
  func saveTableViewAsFile() {
    Debug.log("[saveTableViewAsFile] Needs implementation.")
    // TODO: Export as CSV and prompt user to save file
  }
  
  /// Starts the currency conversion process using columns with the selected headers.
  func performConversionUsingColumnWithHeaders(dates: String, amounts: String, currencies: String, amountsCurrenciesCombined: Bool) {
    Debug.log("[performConversionUsingColumnWithHeaders] dates: \(dates), amounts: \(amounts), currencies: \(currencies), amountsCurrenciesCombined: \(amountsCurrenciesCombined)")
    // TODO: Add column "To CUR" with conversions below
  }
  
  /// Presents DataSelectionView as a sheet presentation style.
  func presentDataSelectionViewAsSheet() {
    let contentView = DataSelectionView(
      sharedHeaders: sharedHeaders,
      onDismiss: { [weak self] in
        NotificationCenter.default.post(name: NSNotification.Name("DismissSheet"), object: nil)
        self?.dismiss(self)
      },
      onConvert: { [weak self] (dates, amounts, currencies, amountsCurrenciesCombined) in
        NotificationCenter.default.post(name: NSNotification.Name("DismissSheet"), object: nil)
        self?.performConversionUsingColumnWithHeaders(dates: dates, amounts: amounts, currencies: currencies, amountsCurrenciesCombined: amountsCurrenciesCombined)
      }
    )
    
    let hostingController = NSHostingController(rootView: contentView)
    self.presentAsSheet(hostingController)
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissSheet"), object: nil, queue: nil) { [weak self] _ in
      self?.dismiss(hostingController)
    }
  }
  
  func initCsvTableScrollView() {
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    
    csvTableView = CSVTableView(frame: .zero, sharedHeaders: sharedHeaders)
    csvTableView.autoresizingMask = [.height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: filterControlsView)
  }
  
  func initFilterControlsView() {
    filterControlsView = NSHostingView(
      rootView: FilterControlsView(
        sharedHeaders: sharedHeaders,
        selectCustomHeaderForTableView: { [weak self] in self?.selectCustomHeaderForTableView() },
        revertTableViewChanges: { [weak self] in self?.revertTableViewChanges() },
        filterTableViewColumnHeaders: { [weak self] (columnHeaders, filterType) in self?.filterTableViewColumnHeaders(columnHeaders, withFilterType: filterType) }
      )
    )
    filterControlsView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(filterControlsView)
    
    filterControlsConstraint = filterControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.filterControlsViewWidth)
    filterControlsConstraint.isActive = true
    
    NSLayoutConstraint.activate([
      filterControlsView.topAnchor.constraint(equalTo: view.topAnchor),
      filterControlsView.bottomAnchor.constraint(equalTo: statusBarViewContainer.topAnchor),
      filterControlsView.widthAnchor.constraint(equalToConstant: Constants.filterControlsViewWidth),
    ])
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    
    let bottomOffset: CGFloat = Constants.statusBarHeight
    let scrollViewHeight = view.bounds.height - bottomOffset
    let scrollViewOriginY = bottomOffset
    scrollView.frame = CGRect(x: 0, y: scrollViewOriginY, width: view.bounds.width - (filterControlsConstraint.constant == 0 ? Constants.filterControlsViewWidth : 0), height: scrollViewHeight)
    
    csvTableView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
  }
  
  
  var filterControlsViewIsHidden = true
  func toggleFilterControlsView() {
    if filterControlsViewIsHidden {
      slideInFilterControlsView()
    } else {
      slideOutFilterControlsView()
    }
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by Constants.filterControlsViewWidth such that is visible on the screen.
   */
  func slideInFilterControlsView() {
    filterControlsConstraint.constant = 0
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }, completionHandler: {
      self.filterControlsViewIsHidden = false
    })
  }
  
  /**
   Animates the position of the FilterControlsView’s trailing anchor by Constants.filterControlsViewWidth such that it is once again out of view entirely.
   */
  func slideOutFilterControlsView() {
    filterControlsConstraint.constant = Constants.filterControlsViewWidth
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      context.allowsImplicitAnimation = true
      view.layoutSubtreeIfNeeded()
    }, completionHandler: {
      self.filterControlsViewIsHidden = true
    })
  }
  
  func filterTableViewColumnHeaders(_ columnHeaders: [String], withFilterType: FilterTableViewInclusionExclusion) {
    if withFilterType == .filterTableViewToOnlyShowColumnsWithHeaders {
      csvTableView.filterTableViewToOnlyShowColumnsWithHeaders(columnHeaders)
    } else {
      csvTableView.filterTableViewToOnlyHideColumnsWithHeaders(columnHeaders)
    }
  }
  
  func enableToolbarButtonsOnFileLoad() {
    windowController?.enableToolbarItemsOnFileLoad()
  }
  
  override var representedObject: Any? {
    didSet {
      if let windowController = representedObject as? WindowController {
        self.windowController = windowController
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DismissSheet"), object: nil)
  }
}
