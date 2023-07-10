//
//  AppStoreConnectSalesColumnHeaders.swift
//  Rates
//
//  Created by Justin Bush on 7/9/23.
//

import Foundation

enum AppStoreConnectSalesColumnHeaders: String {
  case transactionDate = "Transaction Date"
  case settlementDate = "Settlement Date"
  case appleIdentifier = "Apple Identifier"
  case sku = "SKU"
  case title = "Title"
  case developerName = "Developer Name"
  case productTypeIdentifier = "Product Type Identifier"
  case countryOfSale = "Country of Sale"
  case quantity = "Quantity"
  case partnerShare = "Partner Share"
  case extendedPartnerShare = "Extended Partner Share"
  case partnerShareCurrency = "Partner Share Currency"
  case customerPrice = "Customer Price"
  case customerCurrency = "Customer Currency"
  case saleOrReturn = "Sale or Return"
  case promoCode = "Promo Code"
  case orderType = "Order Type"
  case region = "Region"
  
  static var expanded: [String] {
    return [
      AppStoreConnectSalesColumnHeaders.transactionDate.rawValue,
      AppStoreConnectSalesColumnHeaders.settlementDate.rawValue,
      AppStoreConnectSalesColumnHeaders.appleIdentifier.rawValue,
      AppStoreConnectSalesColumnHeaders.sku.rawValue,
      AppStoreConnectSalesColumnHeaders.title.rawValue,
      AppStoreConnectSalesColumnHeaders.quantity.rawValue,
      AppStoreConnectSalesColumnHeaders.extendedPartnerShare.rawValue,
      AppStoreConnectSalesColumnHeaders.partnerShareCurrency.rawValue
    ]
  }
  
  static var simplified: [String] {
    return [
      AppStoreConnectSalesColumnHeaders.settlementDate.rawValue,
      AppStoreConnectSalesColumnHeaders.title.rawValue,
      AppStoreConnectSalesColumnHeaders.extendedPartnerShare.rawValue,
      AppStoreConnectSalesColumnHeaders.partnerShareCurrency.rawValue
    ]
  }
  
}
