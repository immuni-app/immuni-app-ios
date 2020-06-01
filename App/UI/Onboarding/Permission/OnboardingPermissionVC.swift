// OnboardingPermissionVC.swift
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

import Foundation
import Tempura

final class OnboardingPermissionVC: ViewControllerWithLocalState<OnboardingPermissionView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.presentedViewController?.preferredStatusBarStyle ?? .darkContent
  }

  override func setupInteraction() {
    self.rootView.userDidTapDiscoverMore = { [weak self] in
      self?.store.dispatch(Logic.PermissionTutorial.ShowHowImmuniWorks(showFaqButton: false))
    }

    self.rootView.userDidTapClose = { [weak self] in
      self?.store.dispatch(Hide(Screen.fixActiveService, animated: true))
    }
  }
}

extension OnboardingPermissionVC: OnboardingViewController {
  func handleNext() {
    switch self.localState.permissionType {
    case .bluetoothOff:
      self.store.dispatch(Logic.Onboarding.UserDidTapBluetoothOffActionButton())

    case .exposureNotification:
      self.store.dispatch(Logic.Onboarding.UserDidTapExposureActionButton())

    case .pushNotifications:
      self.store.dispatch(Logic.Onboarding.UserDidTapPushPermissions())
    }
  }

  var nextButtonTitle: String {
    switch self.localState.permissionType {
    case .bluetoothOff:
      return L10n.Onboarding.BluetoothOff.action

    case .exposureNotification:
      return L10n.Onboarding.ExposurePermission.action

    case .pushNotifications:
      return L10n.Onboarding.PushPermission.action
    }
  }

  var shouldNextButtonBeEnabled: Bool {
    return true
  }

  var shouldShowBackButton: Bool {
    false
  }

  var shouldShowNextButton: Bool {
    true
  }

  var shouldShowGradient: Bool {
    false
  }
}

struct OnboardingPermissionLS: LocalState {
  /// The type of permission the view is presenting to be checked.
  let permissionType: OnboardingPermissionVM.PermissionType
  /// Whether the view is dismissible and presented in a modal. This will change the close button visibility.
  let canBeDismissed: Bool
}
