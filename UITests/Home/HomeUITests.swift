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

import TempuraTesting
import XCTest

@testable import Immuni

class HomeUITests: AppViewTestCase, ViewTestCase {
  typealias V = HomeView

  var protectionActiveVM: HomeVM {
    return HomeVM(cellTypes: [
      .serviceActiveCard(isServiceActive: true),
      .infoHeader,
      .info(kind: .protection),
      .info(kind: .app),
      .deactivateButton(isEnabled: true)
    ])
  }

  var protectionNotActiveVM: HomeVM {
    return HomeVM(cellTypes: [
      .serviceActiveCard(isServiceActive: false),
      .infoHeader,
      .info(kind: .protection),
      .info(kind: .app),
      .deactivateButton(isEnabled: false)
    ])
  }

  var riskVM: HomeVM {
    return HomeVM(cellTypes: [
      .header(kind: .risk),
      .serviceActiveCard(isServiceActive: true),
      .infoHeader,
      .info(kind: .protection),
      .info(kind: .app),
      .deactivateButton(isEnabled: true)
    ])
  }

  var covidPositiveDisabledVM: HomeVM {
    return HomeVM(cellTypes: [
      .header(kind: .positive),
      .serviceActiveCard(isServiceActive: false),
      .infoHeader,
      .info(kind: .protection),
      .info(kind: .app),
      .deactivateButton(isEnabled: false)
    ])
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
