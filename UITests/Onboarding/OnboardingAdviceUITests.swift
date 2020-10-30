// OnboardingAdviceUITests.swift
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

class OnboardingAdviceUITests: AppViewTestCase, ViewTestCase {
  typealias V = OnboardingAdviceView

  func testUI() {
    let context = UITests.Context<V>(container: UITests.Container.custom { vc in
      guard
        let view = vc.view as? OnboardingAdviceView,
        let model = view.model

      else {
        return vc
      }

      let navController = OnboardingContainerNC(rootViewController: vc)
      let title: String

      switch model.adviceType {
      case .pin:
        title = L10n.Onboarding.PinAdvice.action
      case .communication:
        title = L10n.Onboarding.CommunicationAdvice.action
      }

      navController.accessoryView?.model = OnboardingContainerAccessoryVM(
        shouldShowBackButton: false,
        shouldShowNextButton: true,
        shouldNextButtonBeEnabled: true,
        nextButtonTitle: title,
        shouldShowGradient: false
      )

      navController.accessoryView?.setNeedsLayout()
      navController.accessoryView?.layoutIfNeeded()
      return navController
    }, renderSafeArea: false)

    self.uiTest(
      testCases: [
        "onboarding_pin_advice": OnboardingAdviceVM(adviceType: .pin),
        "onboarding_communication_advice": OnboardingAdviceVM(adviceType: .communication)
      ],
      context: context
    )
  }
}
