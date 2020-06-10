// OnboardingAdviceView.swift
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
import PinLayout
import Tempura

// MARK: - View

class OnboardingAdviceView: UIView, ViewControllerModellableView {
  private static let verticalSpacing: CGFloat = UIDevice.getByScreen(normal: 25, narrow: 10)

  private static let horizontalSpacing: CGFloat = UIDevice.getByScreen(
    normal: OnboardingContainerAccessoryView.horizontalSpacing,
    narrow: OnboardingContainerAccessoryView.horizontalSpacing / 2.0
  )

  private let detailsLabel = UILabel()
  private let titleLabel = UILabel()
  private let image = UIImageView()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.detailsLabel)
    self.addSubview(self.titleLabel)
    self.addSubview(self.image)
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
  }

  // MARK: - Update

  func update(oldModel: OnboardingAdviceVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.titleLabel, content: model.title)
    Self.Style.details(self.detailsLabel, content: model.details)
    Self.Style.image(self.image, image: model.image, accessibilityLabel: model.imageAccessibilityLabel)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.detailsLabel.pin
      .horizontally(Self.horizontalSpacing)
      .bottom(15 + self.safeAreaInsets.bottom)
      .marginBottom(Self.verticalSpacing)
      .sizeToFit(.width)

    self.titleLabel.pin
      .horizontally(Self.horizontalSpacing)
      .above(of: self.detailsLabel, aligned: .left)
      .marginBottom(Self.verticalSpacing)
      .sizeToFit(.width)

    self.image.pin
      .horizontally()
      .top()
      .above(of: self.titleLabel)
      .marginBottom(Self.verticalSpacing)
      .maxHeight(self.bounds.width)
      .align(.top)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    let imageSize = self.image.intrinsicContentSize
    let realImageViewSize = self.image.frame.size

    let isImageRelevant = (realImageViewSize.height / imageSize.height) > 0.3
    self.image.alpha = isImageRelevant.cgFloat
  }
}

// MARK: - Style

private extension OnboardingAdviceView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = UIDevice.getByScreen(normal: TextStyles.h1, narrow: TextStyles.h2)
      let style = textStyle.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: style
      )
    }

    static func details(_ label: UILabel, content: String) {
      let boldStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left)
      )
      let style = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left),
        .xmlRules([.style("b", boldStyle)])
      )
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: style
      )
    }

    static func image(_ imageView: UIImageView, image: UIImage, accessibilityLabel: String?) {
      imageView.image = image
      imageView.contentMode = .scaleAspectFit

      if let label = accessibilityLabel {
        imageView.setAccessibilityLabel(label)
      }
    }
  }
}
