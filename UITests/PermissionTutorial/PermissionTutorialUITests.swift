// PermissionTutorialUITests.swift
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

class PermissionTutorialUITests: AppViewTestCase, ViewTestCase {
  typealias V = PermissionTutorialView
  func testUI() {
    let context = UITests.Context<V>()

    self.uiTest(
      testCases: [
        "permission_tutorial_notification": PermissionTutorialVM(content: .notificationInstructions, isHeaderVisible: false),
        "permission_tutorial_bluetooth": PermissionTutorialVM(content: .bluetoothInstructions, isHeaderVisible: false),
        "permission_tutorial_exposure_notification_unauthorized": PermissionTutorialVM(
          content: .exposureNotificationUnauthorizedInstructions,
          isHeaderVisible: false
        ),
        "permission_tutorial_exposure_notification_restricted": PermissionTutorialVM(
          content: .exposureNotificationRestrictedInstructions,
          isHeaderVisible: false
        ),
        "permission_tutorial_update_os": PermissionTutorialVM(content: .updateOperatingSystem, isHeaderVisible: false),
        "how_immuni_works": PermissionTutorialVM(content: .howImmuniWorks, isHeaderVisible: false)
      ],
      context: context
    )
  }

  func testUIScrolled() {
    let context = UITests.Context<V>(hooks: [
      UITests.Hook.viewDidLayoutSubviews: { view in
        if view.contentCollectionCanScroll {
          view.contentCollection.contentOffset = CGPoint(
            x: 0,
            y: view.contentCollection.contentSize.height - view.contentCollection.frame.height
          )
        } else {
          view.contentCollection.contentOffset = .zero
        }
      }
    ])

    self.uiTest(
      testCases: [
        "permission_tutorial_notification_scrolled": PermissionTutorialVM(
          content: .notificationInstructions,
          isHeaderVisible: true
        ),
        "permission_tutorial_bluetooth_scrolled": PermissionTutorialVM(content: .bluetoothInstructions, isHeaderVisible: true),
        "permission_tutorial_exposure_notification_unauthorized_scrolled": PermissionTutorialVM(
          content: .exposureNotificationUnauthorizedInstructions,
          isHeaderVisible: true
        ),
        "permission_tutorial_exposure_notification_restricted_scrolled": PermissionTutorialVM(
          content: .exposureNotificationRestrictedInstructions,
          isHeaderVisible: true
        ),
        "permission_tutorial_update_os_scrolled": PermissionTutorialVM(content: .updateOperatingSystem, isHeaderVisible: true),
        "how_immuni_works_scrolled": PermissionTutorialVM(content: .howImmuniWorks, isHeaderVisible: true)
      ],
      context: context
    )
  }

  func isViewReady(_ view: PermissionTutorialView, identifier: String) -> Bool {
    guard identifier.contains("_scrolled") else {
      return true
    }

    view.setNeedsLayout()
    return !view.contentCollectionCanScroll || view.contentCollection.contentOffset.y > 0
  }

  func scrollViewsToTest(in view: PermissionTutorialView, identifier: String) -> [String: UIScrollView] {
    return [
      "scroll": view.contentCollection
    ]
  }
}
