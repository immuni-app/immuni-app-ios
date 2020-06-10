// ForceUpdateUITests.swift
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

class ForceUpdateUITests: AppViewTestCase, ViewTestCase {
  typealias V = ForceUpdateView

  func testUI() {
    self.uiTest(
      testCases: [
        "force_update_app": ForceUpdateVM(type: .app),
        "force_update_os": ForceUpdateVM(type: .operatingSystem)
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }
}
