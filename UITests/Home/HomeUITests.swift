// HomeUITests.swift
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

import Models
import TempuraTesting
import XCTest

@testable import Immuni

class HomeUITests: AppViewTestCase, ViewTestCase {
  typealias V = HomeView

  static let mockedLastContact = CalendarDay(year: 2020, month: 3, day: 04)

  var protectionActiveVM: HomeVM {
    return HomeVM(isServiceActive: true, covidStatus: .neutral)
  }

  var protectionNotActiveVM: HomeVM {
    return HomeVM(isServiceActive: false, covidStatus: .neutral)
  }

  var riskVM: HomeVM {
    return HomeVM(isServiceActive: true, covidStatus: .risk(lastContact: Self.mockedLastContact))
  }

  var covidPositiveDisabledVM: HomeVM {
    return HomeVM(isServiceActive: false, covidStatus: .positive(lastUpload: Self.mockedLastContact))
  }

  func testUI() {
    self.uiTest(
      testCases: [
        "home_protection_active": self.protectionActiveVM,
        "home_protection_not_active": self.protectionNotActiveVM,
        "home_contact": self.riskVM,
        "home_covid_positive_disabled": self.covidPositiveDisabledVM
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }

  func scrollViewsToTest(in view: HomeView, identifier: String) -> [String: UIScrollView] {
    return [
      "collection": view.collection
    ]
  }
}
