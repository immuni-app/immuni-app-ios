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
    let context = UITests.Context<V>(renderSafeArea: false)

    self.uiTest(
      testCases: [
        "permission_tutorial_notification": PermissionTutorialVM(
          content: .notificationInstructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_bluetooth": PermissionTutorialVM(
          content: .bluetoothInstructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_unauthorized": PermissionTutorialVM(
          content: .exposureNotificationUnauthorizedInstructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_restricted": PermissionTutorialVM(
          content: .exposureNotificationRestrictedInstructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_deactivate_service": PermissionTutorialVM(
          content: .deactivateServiceInstructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_update_os": PermissionTutorialVM(
          content: .updateOperatingSystem,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_cant_update_os": PermissionTutorialVM(
          content: .cantUpdateOperatingSystem,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "how_immuni_works": PermissionTutorialVM(
          content: .howImmuniWorks(shouldShowFaqButton: false),
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "how_immuni_works_faq": PermissionTutorialVM(
          content: .howImmuniWorks(shouldShowFaqButton: true),
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "how_verify_immuni_works": PermissionTutorialVM(
          content: .verifyImmuniWorks,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "how_to_upload_when_positive": PermissionTutorialVM(
          content: .howToUploadWhenPositive,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "why_province_region": PermissionTutorialVM(
          content: .whyProvinceRegion,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_restricted_or_unauthorized_v2": PermissionTutorialVM(
          content: .exposureNotificationRestrictedOrUnauthorizedV2Instructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_deactivate_service_v2": PermissionTutorialVM(
          content: .deactivateServiceInstructionsV2,
          isHeaderVisible: false,
          shouldAnimateContent: false
        )
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
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_bluetooth_scrolled": PermissionTutorialVM(
          content: .bluetoothInstructions,
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_unauthorized_scrolled": PermissionTutorialVM(
          content: .exposureNotificationUnauthorizedInstructions,
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_restricted_scrolled": PermissionTutorialVM(
          content: .exposureNotificationRestrictedInstructions,
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_deactivate_service_scrolled": PermissionTutorialVM(
          content: .deactivateServiceInstructions,
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_update_os_scrolled": PermissionTutorialVM(
          content: .updateOperatingSystem,
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "how_immuni_works_scrolled": PermissionTutorialVM(
          content: .howImmuniWorks(shouldShowFaqButton: false),
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "how_immuni_works_faq_scrolled": PermissionTutorialVM(
          content: .howImmuniWorks(shouldShowFaqButton: true),
          isHeaderVisible: true,
          shouldAnimateContent: false
        ),
        "permission_tutorial_exposure_notification_restricted_or_unauthorized_v2_scrolled": PermissionTutorialVM(
          content: .exposureNotificationRestrictedOrUnauthorizedV2Instructions,
          isHeaderVisible: false,
          shouldAnimateContent: false
        ),
        "permission_tutorial_deactivate_service_v2_scrolled": PermissionTutorialVM(
          content: .deactivateServiceInstructionsV2,
          isHeaderVisible: false,
          shouldAnimateContent: false
        )
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
