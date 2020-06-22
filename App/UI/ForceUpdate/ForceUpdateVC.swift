// ForceUpdateVC.swift
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
import UIKit

// MARK: - ViewController

class ForceUpdateVC: ViewControllerWithLocalState<ForceUpdateView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Interactions

  override func setupInteraction() {
    self.rootView.didTapUpdate = { [weak self] in
      guard let self = self, let model = self.viewModel else {
        return
      }

      switch model.type {
      case .app:
        self.dispatch(Logic.Shared.OpenAppStorePage())

      case .operatingSystem:
        self.dispatch(Logic.PermissionTutorial.ShowUpdateOperatingSystem())
      }
    }

    self.rootView.didTapSecondaryButton = { [weak self] in
      self?.dispatch(Logic.PermissionTutorial.ShowCantUpdateOperatingSystem())
    }
  }
}

struct ForceUpdateLS: LocalState {
  /// The type of update to force.
  let type: ForceUpdateVM.UpdateType

  init(type: ForceUpdateVM.UpdateType) {
    self.type = type
  }
}
