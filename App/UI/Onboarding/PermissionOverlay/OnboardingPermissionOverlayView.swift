// OnboardingPermissionOverlayView.swift
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

import Tempura

// MARK: - View

class OnboardingPermissionOverlayView: UIView, ViewControllerModellableView {
  // MARK: - Subviews

  let hintLabel = UILabel()

  // MARK: - Interactions

  // MARK: - Setup

  func setup() {
    self.addSubview(self.hintLabel)
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
  }

  // MARK: - Update

  func update(oldModel: OnboardingPermissionOverlayVM?) {
    guard let model = self.model, model != oldModel else { return }

    Self.Style.hint(self.hintLabel, content: model.hint)
    self.setNeedsLayout()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.hintLabel.pin
      .horizontally(30)
      .top(self.safeAreaInsets.top + 20)
      .sizeToFit(.width)
  }
}

// MARK: - Style

extension OnboardingPermissionOverlayView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = UIColor(displayP3Red: 0.247, green: 0.29, blue: 0.451, alpha: 0.8)
    }

    static func hint(_ label: UILabel, content: String) {
      let textStyle = TextStyles.h2Medium.byAdding(
        .color(Palette.white),
        .alignment(.center),
        .xmlRules([
          .style("b", TextStyles.h2)
        ])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
