// OnboardingAdviceVC.swift
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

final class OnboardingAdviceVC: ViewControllerWithLocalState<OnboardingAdviceView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  override func setupInteraction() {}
}

extension OnboardingAdviceVC: OnboardingViewController {
  func handleNext() {
    switch self.localState.adviceType {
    case .pin:
      self.store.dispatch(Logic.Onboarding.UserDidTapPinAdvice())
    case .communication:
      self.store.dispatch(Logic.Onboarding.UserDidTapCommunicationAdvice())
    }
  }

  var nextButtonTitle: String {
    switch self.localState.adviceType {
    case .pin:
      return L10n.Onboarding.PinAdvice.action
    case .communication:
      return L10n.Onboarding.CommunicationAdvice.action
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

struct OnboardingAdviceLS: LocalState {
  /// The type of advice the view is presenting to be checked.
  let adviceType: OnboardingAdviceVM.AdviceType
}
