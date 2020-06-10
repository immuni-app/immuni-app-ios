// WelcomeUITests.swift
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

class WelcomeUITests: AppViewTestCase, ViewTestCase {
  typealias V = WelcomeView

  func testUI() {
    self.uiTest(
      testCases: [
        "welcome_first_page": WelcomeVM(currentPage: 0),
        "welcome_second_page": WelcomeVM(currentPage: 1),
        "welcome_third_page": WelcomeVM(currentPage: 2),
        "welcome_fourth_page": WelcomeVM(currentPage: 3)
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }

  func isViewReady(_ view: WelcomeView, identifier: String) -> Bool {
    switch identifier {
    case "welcome_first_page":
      view.scrollTo(page: 0, animated: false)

    case "welcome_second_page":
      view.scrollTo(page: 1, animated: false)

    case "welcome_third_page":
      view.scrollTo(page: 2, animated: false)

    case "welcome_fourth_page":
      view.scrollTo(page: 3, animated: false)
    default:
      return false
    }

    return true
  }
}
