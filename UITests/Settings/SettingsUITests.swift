// SettingsUITests.swift
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

class SettingsUITests: AppViewTestCase, ViewTestCase {
  typealias V = SettingsView

  var settingsVM: SettingsVM {
    return SettingsVM(
      sections: SettingsVM.defaultSections,
      appName: "Immuni",
      appVersion: "1.2.3 (55)",
      isHeaderVisible: false
    )
  }

  var scrolledVM: SettingsVM {
    return SettingsVM(
      sections: SettingsVM.defaultSections,
      appName: "Immuni",
      appVersion: "1.2.3 (55)",
      isHeaderVisible: true
    )
  }

  func testUI() {
    let context = UITests.Context<V>(renderSafeArea: false)

    self.uiTest(
      testCases: [
        "settings_default": self.settingsVM
      ],
      context: context
    )
  }

  func testUIScrolled() {
    let context = UITests.Context<V>(hooks: [
      UITests.Hook.viewDidLayoutSubviews: { view in
        if view.contentCollectionCanScroll {
          view.collection.contentOffset = CGPoint(x: 0, y: view.collection.contentSize.height - view.collection.frame.height)
        } else {
          view.collection.contentOffset = .zero
        }
      }
    ])

    self.uiTest(
      testCases: [
        "settings_scrolled": self.scrolledVM
      ],
      context: context
    )
  }

  func isViewReady(_ view: SettingsView, identifier: String) -> Bool {
    guard identifier.contains("_scrolled") else {
      return true
    }

    view.setNeedsLayout()
    return !view.contentCollectionCanScroll || view.collection.contentOffset.y > 0
  }

  func scrollViewsToTest(in view: SettingsView, identifier: String) -> [String: UIScrollView] {
    return [
      "collection": view.collection
    ]
  }
}

// MARK: Helpers

extension SettingsView {
  var contentCollectionCanScroll: Bool {
    return self.collection.contentSize.height > self.collection.frame.height + self.collection.contentInset.vertical
  }
}
