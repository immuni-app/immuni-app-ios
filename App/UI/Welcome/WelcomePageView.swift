// WelcomePageView.swift
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

class WelcomePageView: UIView, ModellableView {
  // MARK: - Subviews

  let animationView = AnimationView()
  let titleLabel = UILabel()
  let detailsLabel = UILabel()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  // MARK: - Setup

  func setup() {
    self.addSubview(self.animationView)
    self.addSubview(self.titleLabel)
    self.addSubview(self.detailsLabel)
  }

  // MARK: - Style

  func style() {}

  // MARK: - Update

  func update(oldModel: WelcomePageVM?) {
    guard let model = self.model, model != oldModel else { return }

    Self.Style.animation(self.animationView, content: model.animation.animation, loopMode: model.loopMode)
    Self.Style.title(self.titleLabel, title: model.title)
    Self.Style.details(self.detailsLabel, details: model.details)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.detailsLabel.pin
      .horizontally(WelcomeView.horizontalSpacing)
      .sizeToFit(.width)
      .bottom()

    self.titleLabel.pin
      .horizontally(WelcomeView.horizontalSpacing)
      .sizeToFit(.width)
      .above(of: self.detailsLabel)
      .marginBottom(UIDevice.getByScreen(normal: 30, narrow: 15))

    self.animationView.pin
      .horizontally()
      .top(self.safeAreaInsets.top)
      .above(of: self.titleLabel)
      .marginBottom(30)
      .align(.center)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    let assetSize = self.animationView.intrinsicContentSize
    let realAssetViewSize = self.animationView.frame.size

    let isAssetRelevant = (realAssetViewSize.height / assetSize.height) > 0.3
    self.animationView.alpha = isAssetRelevant.cgFloat
  }

  func playAnimation() {
    self.animationView.playIfPossible()
  }

  func pauseAnimation() {
    self.animationView.pause()
  }
}

// MARK: - Style

extension WelcomePageView {
  enum Style {
    static func animation(_ view: AnimationView, content: Animation?, loopMode: LottieLoopMode) {
      view.animation = content
      view.loopMode = loopMode
      view.backgroundBehavior = .pauseAndRestore
      view.shouldRasterizeWhenIdle = true
    }

    static func title(_ label: UILabel, title: String?) {
      let style = TextStyles.h2.byAdding(
        .color(Palette.grayDark),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: title,
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

// MARK: - View Model

struct WelcomePageVM: ViewModel, Equatable {
  let animation: AnimationAsset
  let loopMode: LottieLoopMode
  let title: String
  let details: String
}

extension WelcomePageVM {
  static var pageOneVM = WelcomePageVM(
    animation: AnimationAsset.welcome1,
    loopMode: .playOnce,
    title: L10n.WelcomeView.Items.First.title,
    details: L10n.WelcomeView.Items.First.description
  )

  static var pageTwoVM = WelcomePageVM(
    animation: AnimationAsset.welcome2,
    loopMode: .loop,
    title: L10n.WelcomeView.Items.Second.title,
    details: L10n.WelcomeView.Items.Second.description
  )

  static var pageThreeVM = WelcomePageVM(
    animation: AnimationAsset.welcome3,
    loopMode: .loop,
    title: L10n.WelcomeView.Items.Third.title,
    details: L10n.WelcomeView.Items.Third.description
  )

  static var pageFourVM = WelcomePageVM(
    animation: AnimationAsset.welcome4,
    loopMode: .loop,
    title: L10n.WelcomeView.Items.Fourth.title,
    details: L10n.WelcomeView.Items.Fourth.description
  )
}
