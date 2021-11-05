// HomeHeaderCardCell.swift
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

import Extensions
import Foundation
import Lottie
import Tempura

struct HomeHeaderCardCellVM: ViewModel {
  let kind: HomeVM.HeaderKind

  var gradient: Gradient {
    switch self.kind {
    case .risk:
      return Palette.gradientRed
    case .positive:
      return Palette.gradientPrimary
    }
  }

  var shadow: UIView.Shadow {
    switch self.kind {
    case .risk:
      return .cardRed
    case .positive:
      return .cardPrimary
    }
  }

  var title: String {
    switch self.kind {
    case .risk:
      return L10n.HomeView.HeaderCard.Risk.title
    case .positive:
      return L10n.HomeView.HeaderCard.Positive.title
    }
  }

  var buttonTitle: String {
    switch self.kind {
    case .risk:
      return L10n.HomeView.HeaderCard.Risk.button
    case .positive:
      return L10n.HomeView.HeaderCard.Positive.button
    }
  }

  var animation: Animation? {
    switch self.kind {
    case .risk:
      return AnimationAsset.contactExtended.animation
    case .positive:
      return nil
    }
  }

  var shouldShowAnimation: Bool {
    return self.animation != nil
  }
}

class HomeHeaderCardCell: UICollectionViewCell, ModellableView, ReusableView, StickyCell {
  typealias VM = HomeHeaderCardCellVM
  private static let topOffset: CGFloat = 20
  private static let titleToButton: CGFloat = 10
  private static let bottomOffset: CGFloat = 30
  private static let labelAnimationMargin: CGFloat = UIDevice.getByScreen(normal: 130, narrow: 100)
  private static let totalVerticalOffset: CGFloat =
    HomeHeaderCardCell.topOffset + HomeHeaderCardCell.bottomOffset + HomeHeaderCardCell.titleToButton

  let shadow = UIView()
  let container = UIView()
  let gradient = GradientView()
  let title = UILabel()
  let icon = AnimationView()
  var infoButton = TextButton()

  var didTapInfo: Interaction?

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

  override var isHighlighted: Bool {
    didSet {
      self.infoButton.isHighlighted = self.isHighlighted
    }
  }

  func setup() {
    self.contentView.addSubview(self.shadow)
    self.shadow.addSubview(self.container)
    self.container.addSubview(self.gradient)
    self.container.addSubview(self.title)
    self.container.addSubview(self.icon)
    self.container.addSubview(self.infoButton)

    self.infoButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapInfo?()
    }
  }

  func style() {
    Self.Style.background(self)
    Self.Style.container(self.container)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.shadow(self.shadow, shadow: model.shadow)
    Self.Style.gradient(self.gradient, gradient: model.gradient)
    Self.Style.title(self.title, content: model.title)
    Self.Style.actionButton(self.infoButton, content: model.buttonTitle)
    Self.Style.warning(self.icon, animation: model.animation)
  }

  var minimumHeight: CGFloat {
    return max(self.superview?.safeAreaInsets.top ?? 0, SharedStyle.cardCornerRadius)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let topSafeArea = self.superview?.safeAreaInsets.top ?? 0

    self.shadow.pin.all()
    self.container.pin.all()
    self.gradient.pin.all()

    self.icon.pin
      .size(50)
      .right(HomeView.cellHorizontalInset)

    let shouldShowAnimation = self.model?.shouldShowAnimation ?? false
    let rightMargin = shouldShowAnimation ? Self.labelAnimationMargin : HomeView.cellHorizontalInset

    self.title.pin
      .left(HomeView.cellHorizontalInset)
      .right(rightMargin)
      .sizeToFit(.width)

    self.infoButton.pin
      .left(HomeView.cellHorizontalInset)
      .right(rightMargin)
      .sizeToFit(.width)

    let neededHeight = self.title.bounds.height + self.infoButton.bounds.height + Self.totalVerticalOffset + topSafeArea
    if neededHeight > self.bounds.height {
      // layout top to bottom
      self.title.pin
        .top(topSafeArea + Self.topOffset)

      self.infoButton.pin
        .below(of: self.title)
        .marginTop(Self.titleToButton)
    } else {
      // layout bottom to top
      self.infoButton.pin
        .bottom(Self.bottomOffset)

      self.title.pin
        .above(of: self.infoButton)
        .marginBottom(Self.titleToButton)
    }

    self.icon.pin
      .top(to: self.title.edge.top)
      .bottom(to: self.infoButton.edge.bottom)
      .align(.center)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    // Needed to handle bottom corners' shadow.
    self.backgroundColor = (self.bounds.height > self.minimumHeight) ? Palette.white : .clear
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let topSafeArea = self.superview?.safeAreaInsets.top ?? 0
    let shouldShowAnimation = self.model?.shouldShowAnimation ?? false
    let rightMargin = shouldShowAnimation ? Self.labelAnimationMargin : HomeView.cellHorizontalInset
    let labelWidth = size.width - HomeView.cellHorizontalInset - rightMargin
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let buttonSize = self.infoButton.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(
      width: size.width,
      height: titleSize.height + buttonSize.height + HomeHeaderCardCell.totalVerticalOffset + topSafeArea
    )
  }
}

private extension HomeHeaderCardCell {
  enum Style {
    static func background(_ view: UIView) {
      view.clipsToBounds = false
      // make sure shadow overlaps next cell
      view.layer.zPosition = 1001
    }

    static func container(_ view: UIView) {
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
      view.clipsToBounds = true
    }

    static func shadow(_ view: UIView, shadow: Shadow) {
      view.addShadow(shadow)
      view.clipsToBounds = false
    }

    static func gradient(_ view: GradientView, gradient: Gradient) {
      view.gradient = gradient
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.h4.byAdding(
        .color(Palette.white),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func actionButton(_ button: TextButton, content: String) {
      let textStyle = TextStyles.s.byAdding(
        .color(Palette.white),
        .alignment(.left),
        .lineHeightMultiple(1)
      )

      button.contentHorizontalAlignment = .left
      button.titleLabel?.numberOfLines = 0
      button.attributedTitle = content.styled(with: textStyle)
    }

    static func warning(_ view: AnimationView, animation: Animation?) {
      view.animation = animation
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.playIfPossible()
    }
  }
}
