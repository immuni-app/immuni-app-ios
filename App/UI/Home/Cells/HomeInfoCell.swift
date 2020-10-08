// HomeInfoCell.swift
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

struct HomeInfoCellVM: ViewModel {
  let kind: HomeVM.InfoKind

    var isAnimation: Bool? {
      switch self.kind {
      case .updateCountry:
        return  false
      default:
        return true
      }
    }

  var animation: Animation? {
    switch self.kind {
    case .protection:
      return AnimationAsset.cardDoctor.animation
    case .app:
      return AnimationAsset.cardPerson.animation
    case .updateCountry:
      return  AnimationAsset.cardPerson.animation
    }
  }

  var title: String {
    switch self.kind {
    case .protection:
      return L10n.HomeView.Info.Protection.title
    case .app:
      return L10n.HomeView.Info.App.title
    case .updateCountry:
        return L10n.HomeView.Info.UpdateCountries.title
    }
  }

  var lightContent: Bool {
    switch self.kind {
    case .protection:
      return true
    case .app:
      return false
    case .updateCountry:
      return false
    }
  }

  var shadow: UIView.Shadow {
    switch self.kind {
    case .protection:
      return .cardPurple
    case .app:
      return .cardLightBlue
    case .updateCountry:
      return .cardLightBlue
    }
  }
}

class HomeInfoCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeInfoCellVM

  private var isAnimation: Bool = true
  private static let containerInset: CGFloat = 25
  private static let iconWidth: CGFloat = UIDevice.getByScreen(normal: 130, narrow: 100)

  let container = UIView()
  let icon = AnimationView()
  let flagEuropa = UIImageView()
  let newEuropa = UIImageView()
  let title = UILabel()
  var actionButton = TextButton()

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
    
    self.container.addSubview(self.icon)
   
    self.container.addSubview(self.flagEuropa)
    self.container.addSubview(self.newEuropa)

    self.container.addSubview(self.title)
    self.container.addSubview(self.actionButton)

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapAction?()
    }
  }

  func style() {}

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
    self.isAnimation = model.isAnimation ?? true
    
    if self.isAnimation {
        Self.Style.icon(self.icon, animation: model.animation)
    }
    else{
        Self.Style.logoEuropa(self.flagEuropa)
        Self.Style.logoNewEuropa(self.newEuropa)

    }
    Self.Style.shadow(self.contentView, shadow: model.shadow)
    Self.Style.container(self.container, lightContent: model.lightContent)
    Self.Style.actionButton(self.actionButton, lightContent: model.lightContent)
    Self.Style.title(self.title, content: model.title, lightContent: model.lightContent)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top(8)
      .bottom(7)
      .horizontally(Self.containerInset)

    self.icon.pin
      .bottom()
      .right()
      .aspectRatio(self.icon.intrinsicContentSize.width / self.icon.intrinsicContentSize.height)
      .width(Self.iconWidth)
    
    self.flagEuropa.pin
      .bottom()
      .right()
      .aspectRatio(self.flagEuropa.intrinsicContentSize.width / self.flagEuropa.intrinsicContentSize.height)
        .width(Self.iconWidth*1)

    self.newEuropa.pin
      .top()
      .left()
      .aspectRatio(self.newEuropa.intrinsicContentSize.width / self.newEuropa.intrinsicContentSize.height)
        .width(Self.iconWidth*0.65)

    self.title.pin
      .left(HomeView.cellHorizontalInset)
      .right(Self.iconWidth)
      .sizeToFit(.width)
      .top(HomeView.cellHorizontalInset)

    self.actionButton.pin
      .left(HomeView.cellHorizontalInset)
      .right(Self.iconWidth)
      .sizeToFit(.width)
      .below(of: self.title)
      .marginTop(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - HomeView.cellHorizontalInset - HomeInfoCell.iconWidth - 2 * HomeInfoCell.containerInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let buttonSize = self.actionButton.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    return CGSize(width: size.width, height: titleSize.height + buttonSize.height + 2 * HomeView.cellHorizontalInset + 15)
  }
}

private extension HomeInfoCell {
  enum Style {
    static func container(_ view: UIView, lightContent: Bool) {
      view.backgroundColor = lightContent ? Palette.purple : Palette.white

      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView, shadow: UIView.Shadow) {
      view.layer.masksToBounds = false
      view.addShadow(shadow)
    }

    static func title(_ label: UILabel, content: String, lightContent: Bool) {
      let textStyle = TextStyles.h4.byAdding(
        .color(lightContent ? Palette.white : Palette.purple),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func actionButton(_ button: TextButton, lightContent: Bool) {
      let content = L10n.HomeView.Info.Button.title
      let textStyle = TextStyles.s.byAdding(
        .color(lightContent ? Palette.white : Palette.purple),
        .alignment(.left),
        .lineHeightMultiple(1)
      )

      button.contentHorizontalAlignment = .left
      button.titleLabel?.numberOfLines = 0
      button.attributedTitle = content.styled(with: textStyle)
    }
    static func logoEuropa(_ imageView: UIImageView) {
        imageView.image = Asset.Home.flagEuropa.image
    }
    static func logoNewEuropa(_ imageView: UIImageView) {
        imageView.image = Asset.Home.newEuropa.image
    }
    

    static func icon(_ view: AnimationView, animation: Animation?) {
      view.animation = animation
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.playIfPossible()
    }
  }
}
