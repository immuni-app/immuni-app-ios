// OnboardingRegionUITests.swift
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

class OnboardingRegionUITests: AppViewTestCase, ViewTestCase {
  typealias V = OnboardingRegionView

  func testUI() {
    let context = UITests.Context<V>(container: UITests.Container.custom { vc in
      let navigationController = OnboardingContainerNC(rootViewController: vc)

      navigationController.accessoryView?.model = OnboardingContainerAccessoryVM(
        shouldShowBackButton: true,
        shouldShowNextButton: true,
        shouldNextButtonBeEnabled: true,
        nextButtonTitle: L10n.Onboarding.Common.next,
        shouldShowGradient: true
      )

      navigationController.accessoryView?.setNeedsLayout()
      navigationController.accessoryView?.layoutIfNeeded()
      return navigationController
    }, renderSafeArea: false)

    self.uiTest(
      testCases: [
        "onboarding_region": OnboardingRegionVM(isHeaderVisible: true, isUpdatingRegion: false, currentRegion: nil),
        "onboarding_region_selected": OnboardingRegionVM(
          isHeaderVisible: true,
          isUpdatingRegion: false,
          currentRegion: Region.lombardia
        )
      ],
      context: context
    )
  }

  func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView] {
    return [
      "scrollable_content": view.contentCollection
    ]
  }
}
