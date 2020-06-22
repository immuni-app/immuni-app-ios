// OnboardingPermissionVM.swift
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
import Katana
import Tempura

struct OnboardingPermissionVM {
  /// The type of permission the view is presenting to be checked.
  let permissionType: PermissionType
  /// Whether the view is dismissible and presented in a modal. This will change the close button visibility.
  let canBeDismissed: Bool

  var title: String {
    switch self.permissionType {
    case .bluetoothOff:
      return L10n.Onboarding.BluetoothOff.title
    case .exposureNotification:
      return L10n.Onboarding.ExposurePermission.title

    case .pushNotifications:
      return L10n.Onboarding.PushPermission.title
    }
  }

  var details: String {
    switch self.permissionType {
    case .bluetoothOff:
      return L10n.Onboarding.BluetoothOff.description
    case .exposureNotification:
      return L10n.Onboarding.ExposurePermission.description
    case .pushNotifications:
      return L10n.Onboarding.PushPermission.description
    }
  }

  var animation: AnimationAsset {
    switch self.permissionType {
    case .bluetoothOff:
      return AnimationAsset.onboardingBluetooth
    case .exposureNotification:
      return AnimationAsset.onboardingExposureNotifications
    case .pushNotifications:
      return AnimationAsset.onboardingPushNotifications
    }
  }

  func shouldUpdateAnimation(oldModel: OnboardingPermissionVM?) -> Bool {
    return self.animation != oldModel?.animation
  }
}

extension OnboardingPermissionVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingPermissionLS) {
    self.permissionType = localState.permissionType
    self.canBeDismissed = localState.canBeDismissed
  }
}

extension OnboardingPermissionVM {
  enum PermissionType {
    case exposureNotification
    case bluetoothOff
    case pushNotifications
  }
}
