// OnboardingPermissionView.swift
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
import Lottie
import PinLayout
import Tempura

// MARK: - View

class OnboardingPermissionView: UIView, ViewControllerModellableView {
  private static let verticalSpacing: CGFloat = UIDevice.getByScreen(normal: 25, narrow: 10)
  private static let horizontalSpacing: CGFloat = UIDevice.getByScreen(
    normal: OnboardingContainerAccessoryView.horizontalSpacing,
    narrow: OnboardingContainerAccessoryView.horizontalSpacing / 2.0
  )
  private static let expectedAssetHeight: CGFloat = 375

  // MARK: - Subviews

  private var discoverMoreButton = TextButton()
  private let detailsLabel = UILabel()
  private let titleLabel = UILabel()
  private let animation = AnimationView()
  private var closeButton = ImageButton()

  // MARK: - Interactions

  var userDidTapDiscoverMore: Interaction?
  var userDidTapClose: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.discoverMoreButton)
    self.addSubview(self.detailsLabel)
    self.addSubview(self.titleLabel)
    self.addSubview(self.animation)
    self.addSubview(self.closeButton)

    self.discoverMoreButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapDiscoverMore?()
    }

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapClose?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
    Self.Style.discoverMore(self.discoverMoreButton, content: L10n.Onboarding.Common.discoverMore)
    OnboardingRegionView.Style.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel: OnboardingPermissionVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.titleLabel, content: model.title)
    Self.Style.details(self.detailsLabel, content: model.details)

    if model.shouldUpdateAnimation(oldModel: oldModel) {
      Self.Style.animation(self.animation, animation: model.animation.animation)
    }

    self.closeButton.isHidden = !model.canBeDismissed
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.discoverMoreButton.pin
      .horizontally(Self.horizontalSpacing)
      .bottom(30 + self.safeAreaInsets.bottom)
      .sizeToFit(.width)

    self.detailsLabel.pin
      .horizontally(Self.horizontalSpacing)
      .above(of: self.discoverMoreButton, aligned: .left)
      .marginBottom(Self.verticalSpacing)
      .sizeToFit(.width)

    self.titleLabel.pin
      .horizontally(Self.horizontalSpacing)
      .above(of: self.detailsLabel, aligned: .left)
      .marginBottom(Self.verticalSpacing)
      .sizeToFit(.width)

    self.animation.pin
      .horizontally()
      .top()
      .above(of: self.titleLabel)
      .marginBottom(Self.verticalSpacing)
      .maxHeight(self.bounds.width)
      .align(.top)

    self.closeButton.pin
      .top(15 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    let realContentViewSize = self.animation.frame.size

    let isContentRelevant = (realContentViewSize.height / Self.expectedAssetHeight) > 0.3
    self.animation.alpha = isContentRelevant.cgFloat
  }
}

// MARK: - Style

private extension OnboardingPermissionView {
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
      let style = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: style
      )
    }

    static func discoverMore(_ button: TextButton, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.left)
      )

      button.contentHorizontalAlignment = .left
      button.contentVerticalAlignment = .bottom
      button.attributedTitle = L10n.WelcomeView.discoverMore.styled(with: textStyle)
      button.titleLabel?.numberOfLines = 0
    }

    static func animation(_ view: AnimationView, animation: Animation?) {
      view.animation = animation
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.playIfPossible()
    }

    static func closeButton(_ btn: ImageButton) {
      SharedStyle.closeButton(btn)
    }
  }
}
