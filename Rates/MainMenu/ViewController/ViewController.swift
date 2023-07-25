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
  @Published var suggestedHeaders: [String?] = [nil]
}

class SharedData: ObservableObject {
  @Published var sqliteUrl: URL?
  @Published var inputUserFile: URL?
  @Published var inputUserFileExtension: FileExtensions?
  @Published var outputUserFile: URL?
  @Published var outputUserFileName: String = ""
  @Published var outputUserFileExtension: FileExtensions = .csv
  @Published var outputUserFileFormat: FileExtensions = .csv
  @Published var saveAllInputDataToOutputFile: Bool = false
  @Published var saveRoundedConversionValuesToOutputFile: Bool = false
}

class SharedFormattingOptions: ObservableObject {
  @Published var roundToTwoDecimalPlaces: Bool = false
  @Published var hideEmptyColumns: Bool = true
  @Published var hideIrrelevantColumns: Bool = true
}

class ViewController: NSViewController {
  
  var appDidLaunch = false
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initMainView()
    initCsvTableScrollView()
    initFilterControlsView()
    disableToolbarButtonsOnFileLoad()
  }
  
  override func viewDidAppear() {
    if !appDidLaunch {
      beginLaunchSession()
      appDidLaunch = true
    }
    
    appDelegate.mainViewDidAppearAndIsReadyForInteraction = true
  }
  
  
  ///
  func userDidOpenFileWithFinderAndWillPassToTableView() -> Bool {
    if let finderFileUrl = appDelegate.userOpenedFileFromFinderWithUrl {
      passFileUrlToTableAndUpdateSharedData(finderFileUrl)
      return true
    }
    return false
  }
  
  func saveTableViewAsFile() {
    presentSaveFileViewAsSheet()
  }
  
  /// This function performs currency conversion on a column of data.
  ///
  /// - Parameters:
  ///   - dates: The header for the dates column.
  ///   - amounts: The header for the amounts column.
  ///   - currencies: The header for the currencies column.
  ///   - amountsCurrenciesCombined: A boolean flag indicating whether the amounts and currencies are combined in the same column.
  ///   - toCurrency: The target currency code for conversion.
  ///
  /// - Returns: Void
  func performConversionUsingColumnWithHeaders(dates: String, amounts: String, currencies: String, amountsCurrenciesCombined: Bool, toCurrency: String) {
    Debug.log("[performConversionUsingColumnWithHeaders] dates: \(dates), amounts: \(amounts), currencies: \(currencies), amountsCurrenciesCombined: \(amountsCurrenciesCombined), toCurrency: \(toCurrency)")
    
    csvTableView.performConversion(toCurrency: toCurrency, usingHeaders: [dates, amounts, currencies])
  }
  
  /// This function initializes the ViewController's main view. Mostly used for first launch.
  ///
  /// The function sets the initial content size of the view's content container, if not overridden by WindowController.
  ///
  /// - Returns: Void
  func initMainView() {
    // Set the initial frame size for the main view.
    let initialWidth: CGFloat = Constants.minimumViewControllerContentWidth
    let initialHeight: CGFloat = Constants.minimumViewControllerContentHeight
    let initialFrame = NSRect(x: 0, y: 0, width: initialWidth, height: initialHeight)
    self.view.frame = initialFrame
  }
  
  /// This function initializes the CSV table scroll view.
  ///
  /// The function creates an instance of `NSScrollView`, enables the vertical and horizontal scrollers, and adds it to the main view of the view controller. The CSV table view is also initialized and added to the scroll view as its document view.
  ///
  /// - Returns: Void
  func initCsvTableScrollView() {
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    
    csvTableView = CSVTableView(frame: .zero, sharedHeaders: sharedHeaders, sharedFormattingOptions: sharedFormattingOptions)
    csvTableView.autoresizingMask = [.height]
    
    scrollView.documentView = csvTableView
    
    view.addSubview(scrollView, positioned: .below, relativeTo: filterControlsView)
  }
  
  /// This function initializes the filter controls view.
  ///
  /// The function creates an instance of `NSHostingView` with a `FilterControlsView` as its root view, and adds it to the main view of the view controller. The filter controls view is set up with constraints to position it correctly within the main view.
  ///
  /// - Returns: Void
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
  
  /// Updates the layout of the scroll view and the CSV table view based on the current view bounds.
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
  /// AppDelegate reference.
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  /// The shared settings used across the app.
  let sharedSettings = SharedSettings()
  /// The shared headers used by the view controller.
  let sharedHeaders = SharedHeaders()
  /// The shared data used by the view controller.
  let sharedData = SharedData()
  /// The shared formatting options to apply to the converted values.
  let sharedFormattingOptions = SharedFormattingOptions()
  /// The delegate for file selection events.
  weak var delegate: FileSelectionDelegate?
  /// The window controller associated with the view controller.
  weak var windowController: WindowController?
  /// The scroll view for the CSV table view.
  private var scrollView: NSScrollView!
  /// The CSV table view.
  var csvTableView: CSVTableView! {
    didSet {
      csvTableView.viewController = self
    }
  }
  
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
  /// A view that will act as an overlay to disable interaction
  var overlayView: NSView?
  /// A view that will act as a drag drope overlay for file input
  var dragDropOverlayView: DragDropOverlayView?
  
  
  /// A flag determining if the user has previously loaded a file this session, or if the CSVTableView is such populated with launch data.
  var userHasPreviouslyLoadedInputFileThisSession = false
  /// A flag determining if CSVTableView is populated with launch screen data.
  var tableIsPopulatedWithLaunchScreenData = false
  
  
  // MARK: - Represented Objects
  override var representedObject: Any? {
    didSet {
      if let windowController = representedObject as? WindowController {
        self.windowController = windowController
      }
    }
  }
  
}


