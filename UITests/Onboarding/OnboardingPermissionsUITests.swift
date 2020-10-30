// OnboardingPermissionsUITests.swift
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

class OnboardingPermissionsUITests: AppViewTestCase, ViewTestCase {
  typealias V = OnboardingPermissionView

  func testUI() {
    let context = UITests.Context<V>(container: UITests.Container.custom { vc in
      guard
        let view = vc.view as? OnboardingPermissionView,
        let model = view.model

      else {
        return vc
      }

      let navigationController = OnboardingContainerNC(rootViewController: vc)
      let title: String

      switch model.permissionType {
      case .bluetoothOff:
        title = L10n.Onboarding.BluetoothOff.action

      case .pushNotifications:
        title = L10n.Onboarding.PushPermission.action

      case .exposureNotification:
        title = L10n.Onboarding.ExposurePermission.action
      }

      navigationController.accessoryView?.model = OnboardingContainerAccessoryVM(
        shouldShowBackButton: false,
        shouldShowNextButton: true,
        shouldNextButtonBeEnabled: true,
        nextButtonTitle: title,
        shouldShowGradient: false
      )

      navigationController.accessoryView?.setNeedsLayout()
      navigationController.accessoryView?.layoutIfNeeded()
      return navigationController
    }, renderSafeArea: false)

    self.uiTest(
      testCases: [
        "onboarding_exposure_permission": OnboardingPermissionVM(permissionType: .exposureNotification, canBeDismissed: false),
        "onboarding_bluetooth_permission": OnboardingPermissionVM(permissionType: .bluetoothOff, canBeDismissed: false),
        "onboarding_push_permission": OnboardingPermissionVM(permissionType: .pushNotifications, canBeDismissed: false)
      ],
      context: context
    )
  }
}
