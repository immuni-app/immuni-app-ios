// OnboardingProvinceUITests.swift
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

class OnboardingProvinceUITests: AppViewTestCase, ViewTestCase {
  typealias V = OnboardingProvinceView

  func testUI() {
    let context = UITests.Context<V>(container: UITests.Container.custom { vc in
      guard
        let view = vc.view as? OnboardingProvinceView,
        let model = view.model

      else {
        return vc
      }

      let navigationController = OnboardingContainerNC(rootViewController: vc)
      let title: String

      if model.isUpdatingProvince {
        title = L10n.Settings.UpdateProvince.updateProvince
      } else {
        title = L10n.Onboarding.Common.next
      }

      navigationController.accessoryView?.model = OnboardingContainerAccessoryVM(
        shouldShowBackButton: true,
        shouldShowNextButton: true,
        shouldNextButtonBeEnabled: true,
        nextButtonTitle: title,
        shouldShowGradient: true
      )

      navigationController.accessoryView?.setNeedsLayout()
      navigationController.accessoryView?.layoutIfNeeded()
      return navigationController
    }, renderSafeArea: false)

    self.uiTest(
      testCases: [
        "onboarding_province": OnboardingProvinceVM(
          isHeaderVisible: true,
          isUpdatingProvince: false,
          selectedRegion: Region.lombardia,
          currentProvince: nil
        ),
        "onboarding_province_selected": OnboardingProvinceVM(
          isHeaderVisible: true,
          isUpdatingProvince: false,
          selectedRegion: Region.lombardia,
          currentProvince: .milano
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
