// ConfirmationView.swift
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
import Tempura

// MARK: - View Model

struct ConfirmationVM: Equatable {
  /// The title shown in the view
  let title: String
  /// The subtitle shown in the view
  let details: String
}

extension ConfirmationVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: ConfirmationLS) {
    self.title = localState.title
    self.details = localState.details
  }
}

// MARK: - View

class ConfirmationView: UIView, ViewControllerModellableView {
  // MARK: - Subviews

  let checkmark = AnimationView()
  let titleLabel = UILabel()
  let detailsLabel = UILabel()

  // MARK: - Interactions

  // MARK: - Setup

  func setup() {
    self.addSubview(self.checkmark)
    self.addSubview(self.titleLabel)
    self.addSubview(self.detailsLabel)
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
    Self.Style.animation(self.checkmark, animation: AnimationAsset.confirmationCheck.animation)
  }

  // MARK: - Update

  func update(oldModel: ConfirmationVM?) {
    guard let model = self.model, model != oldModel else { return }

    Self.Style.title(self.titleLabel, content: model.title)
    Self.Style.details(self.detailsLabel, details: model.details)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.titleLabel.pin
      .horizontally(30)
      .sizeToFit(.width)
      .top(to: self.edge.vCenter)

    self.checkmark.pin
      .size(100)
      .hCenter()
      .bottom(to: self.edge.vCenter)

    self.detailsLabel.pin
      .horizontally(30)
      .below(of: self.titleLabel)
      .marginTop(20)
      .sizeToFit(.width)
  }
}

// MARK: - Style

extension ConfirmationView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func animation(_ view: AnimationView, animation: Animation?) {
      view.animation = animation
      view.loopMode = .playOnce
      view.playIfPossible()
    }

    static func title(_ label: UILabel, content: String) {
      let style = TextStyles.h1.byAdding(
        .color(Palette.grayDark),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: style
      )
    }

    static func details(_ label: UILabel, details: String?) {
      let style = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: details,
        style: style
      )
    }
  }
}
