// AppSetupView.swift
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

import Lottie
import PinLayout
import Tempura

// MARK: - ViewModel

struct AppSetupVM: ViewModelWithState {}

extension AppSetupVM {
  init?(state: AppState) {
    return nil
  }
}

// MARK: - View

class AppSetupView: UIView, ViewControllerModellableView {
  // MARK: - Subviews

  private let spinner = AnimationView()
  private let logo = UIImageView()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.spinner)
    self.addSubview(self.logo)
  }

  /// Meant to be called by the VC when the app did appear.
  /// Doing this before the layout (e.g. in the setup)
  /// would cause lottie to fail. Doing it in the update
  /// might be too late.
  func setupAnimation() {
    self.spinner.playIfPossible()
  }

  // MARK: - Style

  func style() {
    AppSetupView.Style.mainView(self)
    AppSetupView.Style.spinner(self.spinner)
    AppSetupView.Style.logo(self.logo)
  }

  // MARK: - Update

  func update(oldModel: AppSetupVM?) {}

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.logo.pin
      .center()
      .sizeToFit()

    self.spinner.pin
      .center()
      .size(120)
  }
}

// MARK: - Style

private extension AppSetupView {
  enum Style {
    static func mainView(_ mainView: AppSetupView) {
      mainView.backgroundColor = Palette.white
    }

    static func spinner(_ spinner: AnimationView) {
      spinner.animation = AnimationAsset.appsetupLoader.animation
      spinner.loopMode = .loop
    }

    static func logo(_ imageView: UIImageView) {
      imageView.image = Asset.AppSetup.logoNoBackground.image
    }
  }
}
