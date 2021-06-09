// ConfirmationVC.swift
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

import Katana
import Tempura

class ConfirmationVC: ViewControllerWithLocalState<ConfirmationView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }
}

extension ConfirmationVC: OnboardingViewController {
  func handleNext() {}
  var shouldNextButtonBeEnabled: Bool { false }
  var shouldShowBackButton: Bool { false }
  var nextButtonTitle: String { "" }
  var shouldShowNextButton: Bool { false }
  var shouldShowGradient: Bool { false }
}

// MARK: - Local State

struct ConfirmationLS: LocalState {
  /// The title shown in the view
  let title: String
  /// The subtitle shown in the view
  let details: String
}

extension ConfirmationLS {
  static var onboardingCompleted: Self {
    return .init(title: L10n.Onboarding.Complete.title, details: "")
  }

  static var uploadDataCompleted: Self {
    return .init(title: L10n.ConfirmData.Confirmation.title, details: L10n.ConfirmData.Confirmation.subtitle)
  }
  static var generateGreenCertificateCompleted: Self {
    return .init(title: L10n.ConfirmData.GreenCertificate.title, details: "")
  }
  static var saveGreenCertificateCompleted: Self {
    return .init(title: L10n.ConfirmData.GreenCertificateSaved.title, details: "")
  }
}
