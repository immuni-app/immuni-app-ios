// CustomerSupportUITests.swift
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import TempuraTesting
import XCTest

@testable import Immuni

class CustomerSupportUITests: AppViewTestCase, ViewTestCase {
  typealias V = CustomerSupportView

  let defaultCells: [CustomerSupportVM.CellType] = CustomerSupportVM.cells(
    supportPhone: "800912491",
    supportPhoneOpeningTime: "7",
    supportPhoneClosingTime: "22",
    supportEmail: "email@email.it",
    osVersion: "iOS 13.1.5",
    deviceModel: "iPhone XS",
    exposureNotificationEnabled: true,
    bluetoothEnabled: true,
    appVersion: "1.0.0 (23)",
    networkReachabilityStatus: .reachable(.ethernetOrWiFi),
    lastENCheck: Date(timeIntervalSince1970: 1_592_984_761)
  )

  let disabledServicesCells: [CustomerSupportVM.CellType] = CustomerSupportVM.cells(
    supportPhone: nil,
    supportPhoneOpeningTime: nil,
    supportPhoneClosingTime: nil,
    supportEmail: nil,
    osVersion: "iOS 13.1.5",
    deviceModel: "iPhone XS",
    exposureNotificationEnabled: false,
    bluetoothEnabled: false,
    appVersion: "1.0.0 (23)",
    networkReachabilityStatus: .notReachable,
    lastENCheck: nil
  )

  let mobileDataCells: [CustomerSupportVM.CellType] = CustomerSupportVM.cells(
    supportPhone: "800912491",
    supportPhoneOpeningTime: "7",
    supportPhoneClosingTime: "22",
    supportEmail: nil,
    osVersion: "iOS 13.1.5",
    deviceModel: "iPhone XS",
    exposureNotificationEnabled: true,
    bluetoothEnabled: false,
    appVersion: "1.0.0 (23)",
    networkReachabilityStatus: .reachable(.cellular),
    lastENCheck: Date(timeIntervalSince1970: 1_592_984_761)
  )

  func testUI() {
    self.uiTest(
      testCases: [
        "customer_support_default": CustomerSupportVM(cells: self.defaultCells, isHeaderVisible: false),
        "customer_support_all_disabled": CustomerSupportVM(cells: self.disabledServicesCells, isHeaderVisible: false),
        "customer_support_mobile_data": CustomerSupportVM(cells: self.mobileDataCells, isHeaderVisible: false),
        "customer_support_scrolled": CustomerSupportVM(cells: self.defaultCells, isHeaderVisible: true)
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }

  func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView] {
    return [
      "scrollable_content": view.contentCollection
    ]
  }
}
