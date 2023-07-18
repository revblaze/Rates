//
//  ViewController.swift
//  Rates
//
//  Created by Justin Bush on 7/7/23.
//

import Cocoa
import SwiftUI
import Combine

class SharedHeaders: ObservableObject {
  @Published var availableCurrencyCodeHeaders: [String] = []
  @Published var availableHeaders: [String] = []
  @Published var suggestedHeaders: [String] = []
  @Published var sqliteUrl: URL?
}

protocol FileSelectionDelegate: AnyObject {
  func fileSelected(_ viewController: ViewController, fileURL: URL)
}

class ViewController: NSViewController {
  
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
  
  /**
   This function performs currency conversion on a column of data.
   
   The function expects the headers for dates, amounts, and currencies. It also needs to know if the amounts and currencies are combined in the same column, as well as the target currency for conversion.
   
   - Parameters:
   - dates: The header for the dates column.
   - amounts: The header for the amounts column.
   - currencies: The header for the currencies column.
   - amountsCurrenciesCombined: A boolean flag indicating whether the amounts and currencies are combined in the same column.
   - toCurrency: The target currency code for conversion.
   
   - Returns: Void
   */
  func performConversionUsingColumnWithHeaders(dates: String, amounts: String, currencies: String, amountsCurrenciesCombined: Bool, toCurrency: String) {
    Debug.log("[performConversionUsingColumnWithHeaders] dates: \(dates), amounts: \(amounts), currencies: \(currencies), amountsCurrenciesCombined: \(amountsCurrenciesCombined), toCurrency: \(toCurrency)")
    
    csvTableView.performConversion(toCurrency: toCurrency, usingHeaders: [dates, amounts, currencies])
  }
  
  /**
   This function initializes the CSV table scroll view.
   
   The function creates an instance of `NSScrollView`, enables the vertical and horizontal scrollers, and adds it to the main view of the view controller. The CSV table view is also initialized and added to the scroll view as its document view.
   
   - Returns: Void
   */
  func initCsvTableScrollView() {
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    
    csvTableView = CSVTableView(frame: .zero, sharedHeaders: sharedHeaders)
    csvTableView.autoresizingMask = [.height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: filterControlsView)
  }
  
  
  /**
   This function initializes the filter controls view.
   
   The function creates an instance of `NSHostingView` with a `FilterControlsView` as its root view, and adds it to the main view of the view controller. The filter controls view is set up with constraints to position it correctly within the main view.
   
   - Returns: Void
   */
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
  
  /**
   Updates the layout of the scroll view and the CSV table view based on the current view bounds.
   */
  func updateScrollViewLayout() {
    let bottomOffset: CGFloat = Constants.statusBarHeight
    let scrollViewHeight = view.bounds.height - bottomOffset
    let scrollViewOriginY = bottomOffset
    scrollView.frame = CGRect(x: 0, y: scrollViewOriginY, width: view.bounds.width - (filterControlsConstraint.constant == 0 ? Constants.filterControlsViewWidth : 0), height: scrollViewHeight)
    
    csvTableView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    
    updateScrollViewLayout()
  }
  
  
  
  // MARK: - Variables
  /// The shared headers used by the view controller.
  let sharedHeaders = SharedHeaders()
  /// The delegate for file selection events.
  weak var delegate: FileSelectionDelegate?
  /// The window controller associated with the view controller.
  weak var windowController: WindowController?
  /// The CSV table view.
  var csvTableView: CSVTableView!
  /// The scroll view for the CSV table view.
  private var scrollView: NSScrollView!
  
  // MARK: - FilterControls View
  /// The view hosting the filter controls.
  var filterControlsView: NSHostingView<FilterControlsView>!
  /// The constraint for the filter controls view.
  var filterControlsConstraint: NSLayoutConstraint!
  /// The state of the filter controls view's current display on the main ViewController.
  var filterControlsViewIsHidden = true
  
  // MARK: - StatusBar View
  /// The state of the status bar.
  var statusBarState: StatusBarState? = .loading
  /// The container view for the status bar.
  @IBOutlet weak var statusBarViewContainer: NSView!
  /// The button in the status bar.
  @IBOutlet weak var statusBarButton: NSButton!
  /// The text field in the status bar.
  @IBOutlet weak var statusBarText: NSTextField!
  /// The progress bar in the status bar.
  @IBOutlet weak var statusBarProgressBar: NSProgressIndicator!
  /// The refresh button in the status bar.
  @IBOutlet weak var statusBarRefreshButton: NSButton!
  /// A flag indicating if the status bar button is pulsing.
  var statusBarButtonIsPulsing = false
  
  // MARK: - Represented Objects
  override var representedObject: Any? {
    didSet {
      if let windowController = representedObject as? WindowController {
        self.windowController = windowController
      }
    }
  }
  
}
