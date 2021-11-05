// HomeServiceActiveCell.swift
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

struct HomeServiceActiveCellVM: ViewModel {
  let isServiceActive: Bool
  let hasHeaderCard: Bool

  var title: String {
    if self.isServiceActive {
      return L10n.HomeView.Service.Active.title
    } else {
      return L10n.HomeView.Service.NotActive.title
    }
  }

  var titleHighlightColor: UIColor {
    if self.isServiceActive {
      return Palette.primary
    } else {
      return Palette.red
    }
  }

  var subtitle: String {
    if self.isServiceActive {
      return L10n.HomeView.Service.Active.subtitle
    } else {
      return L10n.HomeView.Service.NotActive.subtitle
    }
  }

  var buttonColor: UIColor {
    return self.hasHeaderCard ? Palette.grayDark : Palette.red
  }

  var buttonShadow: UIView.Shadow {
    return self.hasHeaderCard ? .grayDark : .cardRed
  }
}

class HomeServiceActiveCell: UICollectionViewCell, ModellableView, ReusableView, StickyCell {
  typealias VM = HomeServiceActiveCellVM

  static let containerShadowOffset: CGFloat = 30
  static let verticalOffset: CGFloat = 30
  static let titleToSubtitle: CGFloat = 15
  static let titleToLogo: CGFloat = 22
  static let subtitleToDiscoverMore: CGFloat = 10
  static let buttonToSubtitle: CGFloat = 18
  static let titleRightMargin: CGFloat = UIDevice.getByScreen(normal: 140, narrow: 100)
  static let animationSize: CGFloat = UIDevice.getByScreen(normal: 160, narrow: 130)
  static let animationOffset: CGFloat = UIDevice.getByScreen(normal: 33, narrow: 27)

  let statusBarBackground = UIView()
  let container = UIView()
  let logo = UIImageView()
  let title = UILabel()
  let subtitle = UILabel()
  let shieldCheckmark = AnimationView()
  let shieldShadow = AnimationView()
  let disabledShield = AnimationView()
  let discoverMore = UILabel()
  var actionButton = ButtonWithInsets()

  var didTapAction: Interaction?

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
      self.actionButton.isHighlighted = self.isHighlighted
    }
  }

  func setup() {
    self.contentView.addSubview(self.container)
    self.contentView.addSubview(self.statusBarBackground)
    self.container.addSubview(self.logo)
    self.container.addSubview(self.title)
    self.container.addSubview(self.subtitle)
    self.container.addSubview(self.shieldShadow)
    self.container.addSubview(self.shieldCheckmark)
    self.container.addSubview(self.disabledShield)
    self.container.addSubview(self.actionButton)
    self.container.addSubview(self.discoverMore)

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapAction?()
    }

    self.discoverMore.accessibilityTraits = .button
  }

  func style() {
    // make sure next cells won't cover this
    self.layer.zPosition = 1000

    Self.Style.container(self.container)
    Self.Style.statusBarBackground(self.statusBarBackground)
    Self.Style.discoverMore(self.discoverMore, content: L10n.HomeView.Service.Active.discoverMore)
    Self.Style.logo(self.logo)
    Self.Style.shieldShadow(self.shieldShadow)
    Self.Style.shieldCheckmark(self.shieldCheckmark)
    Self.Style.shieldDisabled(self.disabledShield)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    self.shieldShadow.isHidden = !model.isServiceActive
    self.shieldCheckmark.isHidden = !model.isServiceActive
    self.disabledShield.isHidden = model.isServiceActive
    self.discoverMore.isHidden = !model.isServiceActive
    self.statusBarBackground.isHidden = model.hasHeaderCard
    self.actionButton.isHidden = model.isServiceActive

    if model.isServiceActive {
      self.shieldShadow.playIfPossible()
      self.shieldCheckmark.playIfPossible()
      self.disabledShield.stop()
    } else {
      self.shieldShadow.stop()
      self.shieldCheckmark.stop()
      self.disabledShield.playIfPossible()
    }

    Self.Style.title(self.title, content: model.title, boldColor: model.titleHighlightColor)
    Self.Style.subtitle(self.subtitle, content: model.subtitle)

    SharedStyle.primaryButton(
      self.actionButton,
      title: L10n.HomeView.Service.NotActive.button,
      tintColor: Palette.white,
      backgroundColor: model.buttonColor,
      cornerRadius: 26,
      shadow: model.buttonShadow
    )
  }

  var minimumHeight: CGFloat {
    return max(self.superview?.safeAreaInsets.top ?? 0, SharedStyle.cardCornerRadius)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.statusBarBackground.pin
      .top()
      .horizontally()
      .height(self.superview?.safeAreaInsets.top ?? 0)

    self.container.pin
      .horizontally()
      .top()
      .bottom(Self.containerShadowOffset)

    let isServiceActive = self.model?.isServiceActive ?? false

    self.actionButton.pin
      .horizontally(HomeView.cellHorizontalInset)
      .sizeToFit(.width)
      .minHeight(53)
      .bottom(HomeView.cellHorizontalInset)

    self.discoverMore.pin
      .horizontally(HomeView.cellHorizontalInset)
      .sizeToFit(.widthFlexible)
      .bottom(HomeServiceActiveCell.verticalOffset)

    if isServiceActive {
      self.subtitle.pin
        .left(HomeView.cellHorizontalInset)
        .right(Self.titleRightMargin)
        .sizeToFit(.width)
        .above(of: self.discoverMore)
        .marginBottom(Self.subtitleToDiscoverMore)
    } else {
      self.subtitle.pin
        .left(HomeView.cellHorizontalInset)
        .right(Self.titleRightMargin)
        .sizeToFit(.width)
        .above(of: self.actionButton)
        .marginBottom(Self.buttonToSubtitle)
    }

    self.title.pin
      .left(HomeView.cellHorizontalInset)
      .right(Self.titleRightMargin)
      .sizeToFit(.width)
      .above(of: self.subtitle)
      .marginBottom(Self.titleToSubtitle)

    self.logo.pin
      .sizeToFit()
      .left(28)
      .above(of: self.title)
      .marginBottom(Self.titleToLogo)

    self.shieldShadow.pin
      .top(to: self.logo.edge.top)
      .right(-Self.animationOffset)
      .size(Self.animationSize)

    self.shieldCheckmark.pin
      .size(of: self.shieldShadow)
      .center(to: self.shieldShadow.anchor.center)

    self.disabledShield.pin
      .size(of: self.shieldShadow)
      .center(to: self.shieldShadow.anchor.center)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let isServiceActive = self.model?.isServiceActive ?? false

    if isServiceActive {
      return self.serviceActiveSize(size)
    } else {
      return self.serviceNotActiveSize(size)
    }
  }

  private func serviceActiveSize(_ size: CGSize) -> CGSize {
    let topSafeArea = self.superview?.safeAreaInsets.top ?? 0
    let labelWidth = size.width - HomeView.cellHorizontalInset - HomeServiceActiveCell.titleRightMargin
    let logoSize = self.logo.intrinsicContentSize
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let firstCellOffset: CGFloat = (self.model?.hasHeaderCard ?? false) ? 0 : topSafeArea
    let discoverMoreSize = self.discoverMore.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    return CGSize(
      width: size.width,
      height:
      logoSize.height +
        titleSize.height +
        subtitleSize.height +
        discoverMoreSize.height +
        2 * HomeServiceActiveCell.verticalOffset +
        HomeServiceActiveCell.titleToLogo +
        HomeServiceActiveCell.titleToSubtitle +
        HomeServiceActiveCell.containerShadowOffset +
        HomeServiceActiveCell.subtitleToDiscoverMore +
        firstCellOffset
    )
  }

  private func serviceNotActiveSize(_ size: CGSize) -> CGSize {
    let topSafeArea = self.superview?.safeAreaInsets.top ?? 0
    let labelWidth = size.width - HomeView.cellHorizontalInset - HomeServiceActiveCell.titleRightMargin
    let logoSize = self.logo.intrinsicContentSize
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let firstCellOffset: CGFloat = (self.model?.hasHeaderCard ?? false) ? 0 : topSafeArea
    let buttonSize = self.actionButton.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let buttonHeight = max(buttonSize.height, 53)

    return CGSize(
      width: size.width,
      height:
      logoSize.height +
        titleSize.height +
        subtitleSize.height +
        buttonHeight +
        2 * HomeServiceActiveCell.verticalOffset +
        HomeServiceActiveCell.titleToLogo +
        HomeServiceActiveCell.titleToSubtitle +
        HomeServiceActiveCell.buttonToSubtitle +
        HomeServiceActiveCell.containerShadowOffset +
        firstCellOffset
    )
  }
}

private extension HomeServiceActiveCell {
  enum Style {
    static func statusBarBackground(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

      view.addShadow(.headerLightBlue)
    }

    static func title(_ label: UILabel, content: String, boldColor: UIColor) {
      let bold = TextStyles.protectionCardHeader.byAdding(
        .color(boldColor),
        .alignment(.left)
      )
      let textStyle = TextStyles.protectionCardHeader.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
          .style("b", bold)
        ])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func subtitle(_ label: UILabel, content: String) {
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func shieldShadow(_ animation: AnimationView) {
      animation.animation = AnimationAsset.shieldBackground.animation
      animation.loopMode = .loop
      animation.backgroundBehavior = .pauseAndRestore
    }

    static func shieldCheckmark(_ animation: AnimationView) {
      animation.animation = AnimationAsset.shieldCheckmark.animation
      animation.loopMode = .playOnce
    }

    static func shieldDisabled(_ animation: AnimationView) {
      animation.animation = AnimationAsset.shieldDisabled.animation
      animation.loopMode = .loop
      animation.backgroundBehavior = .pauseAndRestore
    }

    static func logo(_ imageView: UIImageView) {
      imageView.image = Asset.Home.logoHorizontal.image
      imageView.setAccessibilityLabel(L10n.Accessibility.appName)
    }

    static func discoverMore(_ label: UILabel, content: String) {
      let style = TextStyles.pSemibold.byAdding(
        .color(Palette.primary)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: style
      )
    }
  }
}
