// PrivacyUITests.swift
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

class PrivacyUITests: AppViewTestCase, ViewTestCase {
  typealias V = PrivacyView

  func testUI() {
    self.uiTest(
      testCases: [
        "privacy_initial": PrivacyVM.onboardingPrivacy(
          isHeaderVisible: true,
          touURL: nil,
          privacyNoticeURL: nil,
          isAbove14Checked: false,
          isAbove14Errored: false,
          isReadPrivacyNoticeChecked: false,
          isReadPrivacyNoticeErrored: false
        ),

        "privacy_checked": PrivacyVM.onboardingPrivacy(
          isHeaderVisible: true,
          touURL: nil,
          privacyNoticeURL: nil,
          isAbove14Checked: true,
          isAbove14Errored: false,
          isReadPrivacyNoticeChecked: true,
          isReadPrivacyNoticeErrored: false
        ),

        "privacy_errored": PrivacyVM.onboardingPrivacy(
          isHeaderVisible: true,
          touURL: nil,
          privacyNoticeURL: nil,
          isAbove14Checked: false,
          isAbove14Errored: true,
          isReadPrivacyNoticeChecked: false,
          isReadPrivacyNoticeErrored: true
        ),

        "settings_privacy": PrivacyVM.settingsPrivacy(isHeaderVisible: false),
        "settings_privacy_header_visible": PrivacyVM.settingsPrivacy(isHeaderVisible: true)
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
