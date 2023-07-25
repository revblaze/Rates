//
//  TableMenu.swift
//  Rates
//
//  Created by Justin Bush on 7/24/23.
//

import Cocoa

extension AppDelegate {
  
  func enableTableMenuItems() {
    enableMenuItem(toggleFiltersSidebarMenuItem, action: #selector(toggleFiltersSidebarMenuItemAction(_:)))
    enableMenuItem(toggleHiddenColumnsMenuItem, action: #selector(toggleHiddenColumnsMenuItemAction(_:)))
    enableMenuItem(toggleRoundToTwoDecimalPlacesMenuItem, action: #selector(toggleRoundToTwoDecimalPlacesMenuItemAction(_:)))
    enableMenuItem(convertToCurrencyMenuItem, action: #selector(convertToCurrencyMenuItemAction(_:)))
  }
  
  @IBAction func toggleFiltersSidebarMenuItemAction(_ sender: Any) {
    Debug.log("[toggleFiltersSidebarMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.toggleFilterControlsView()
    }
  }
  
  @IBAction func toggleHiddenColumnsMenuItemAction(_ sender: Any) {
    Debug.log("[toggleHiddenColumnsMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.toggleHiddenTableViewColumns()
    }
  }
  
  @IBAction func toggleRoundToTwoDecimalPlacesMenuItemAction(_ sender: Any) {
    Debug.log("[toggleRoundToTwoDecimalPlacesMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.toggleRoundToTwoDecimalPlaces()
    }
  }
  
  @IBAction func convertToCurrencyMenuItemAction(_ sender: Any) {
    Debug.log("[convertToCurrencyMenuItemAction]")
    performActionOnViewController { viewController in
      viewController.presentDataSelectionViewAsSheet()
    }
  }
  
  func toggleFiltersSidebarMenuItemText(withShowState showState: Bool) {
    Debug.log("[toggleFiltersSidebarMenuItemText] withShowState: \(showState)")
    let menuItemLabel = showState ? "Show Filters Sidebar" : "Hide Filters Sidebar"
    DispatchQueue.main.async {
      self.toggleFiltersSidebarMenuItem.title = menuItemLabel
    }
  }
  
  func toggleHiddenColumnsMenuItemText(withDefaultState state: Bool) {
    Debug.log("[toggleShowHiddenColumnsItemText] withDefaultState: \(state)")
    let menuItemLabel = state ? "Show Hidden Columns" : "Hide Irrelevant Columns"
    DispatchQueue.main.async {
      self.toggleHiddenColumnsMenuItem.title = menuItemLabel
    }
  }
  
  func toggleRoundToTwoDecimalPlacesMenuItemText(withDefaultState state: Bool) {
    Debug.log("[toggleRoundToTwoDecimalPlacesMenuItemText] withDefaultState: \(state)")
    let menuItemLabel = state ? "Undo Round to Two Decimal Places" : "Round to Two Decimal Places"
    DispatchQueue.main.async {
      self.toggleRoundToTwoDecimalPlacesMenuItem.title = menuItemLabel
    }
  }
  
}


//  @IBOutlet weak var toggleFiltersSidebarMenuItem: NSMenuItem!
//  @IBOutlet weak var toggleHiddenColumnsMenuItem: NSMenuItem!
//  @IBOutlet weak var toggleRoundToTwoDecimalPlacesMenuItem: NSMenuItem!
//  @IBOutlet weak var convertToCurrencyMenuItem: NSMenuItem!
