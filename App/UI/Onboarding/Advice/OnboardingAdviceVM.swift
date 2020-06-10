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
    case pilot
  }

  /// The type of advice the view is presenting to be checked.
  let adviceType: AdviceType

  var title: String {
    switch self.adviceType {
    case .pin:
      return L10n.Onboarding.PinAdvice.title
    case .communication:
      return L10n.Onboarding.CommunicationAdvice.title
    case .pilot:
      return L10n.Onboarding.Pilot.title
    }
  }

  var details: String {
    switch self.adviceType {
    case .pin:
      return L10n.Onboarding.PinAdvice.description
    case .communication:
      return L10n.Onboarding.CommunicationAdvice.description
    case .pilot:
      return L10n.Onboarding.Pilot.description
    }
  }

  var image: UIImage {
    switch self.adviceType {
    case .pin:
      return Asset.Onboarding.advicePin.image
    case .communication:
      return Asset.Onboarding.adviceCommunication.image
    case .pilot:
      return Asset.Onboarding.pilotMessage.image
    }
  }

  var imageAccessibilityLabel: String? {
    switch self.adviceType {
    case .pin:
      return L10n.Accessibility.Image.Onboarding.pinAdvice
    case .communication:
      return L10n.Accessibility.Image.Onboarding.communicationAdvice
    case .pilot:
      return nil
    }
  }
}

extension OnboardingAdviceVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingAdviceLS) {
    self.adviceType = localState.adviceType
  }
}
