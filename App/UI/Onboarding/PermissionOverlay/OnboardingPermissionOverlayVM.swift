// OnboardingPermissionOverlayVM.swift
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

struct OnboardingPermissionOverlayVM: Equatable {
  /// The type of permission that is going to be requested.
  let type: OnboardingPermissionOverlayVM.OverlayType

  var hint: String {
    switch self.type {
    case .exposureNotification:
      return L10n.Onboarding.ExposurePermission.Overlay.hint

    case .pushNotification:
      return L10n.Onboarding.PushPermission.Overlay.hint

    case .diagnosisKeys:
      return L10n.UploadData.DiagnosisKeys.Overlay.hint
    }
  }
}

extension OnboardingPermissionOverlayVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingPermissionOverlayLS) {
    self.type = localState.type
  }
}

extension OnboardingPermissionOverlayVM {
  enum OverlayType {
    case exposureNotification
    case pushNotification
    case diagnosisKeys
  }
}
