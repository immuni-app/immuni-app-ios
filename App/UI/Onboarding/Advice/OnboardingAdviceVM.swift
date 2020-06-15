// OnboardingAdviceVM.swift
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

struct OnboardingAdviceVM {
  enum AdviceType {
    case pin
    case communication
  }

  /// The type of advice the view is presenting to be checked.
  let adviceType: AdviceType

  var title: String {
    switch self.adviceType {
    case .pin:
      return L10n.Onboarding.PinAdvice.title
    case .communication:
      return L10n.Onboarding.CommunicationAdvice.title
    }
  }

  var details: String {
    switch self.adviceType {
    case .pin:
      return L10n.Onboarding.PinAdvice.description
    case .communication:
      return L10n.Onboarding.CommunicationAdvice.description
    }
  }

  var animation: AnimationAsset {
    switch self.adviceType {
    case .pin:
      return AnimationAsset.onboardingPinAdvice
    case .communication:
      return AnimationAsset.onboardingCommunicationAdvice
    }
  }

  func shouldUpdateAnimation(oldModel: OnboardingAdviceVM?) -> Bool {
    return self.animation != oldModel?.animation
  }
}

extension OnboardingAdviceVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingAdviceLS) {
    self.adviceType = localState.adviceType
  }
}
