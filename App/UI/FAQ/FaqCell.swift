// FaqCell.swift
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
import Models
import Tempura

struct FaqCellVM: ViewModel {
  let faq: FAQ
  let searchFilter: String

  var title: String {
    return self.faq.title
      .replacingOccurrences(of: self.searchFilter, with: "<b>\(self.searchFilter)</b>", options: .caseInsensitive)
  }
}

class FaqCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = FaqCellVM

  static let containerInset: CGFloat = 25
  static let cellInset: CGFloat = 25
  static let chevronInset: CGFloat = 30
  static let chevronSize: CGFloat = 24
  static let titleToChevron: CGFloat = 15

  let container = UIView()
  let title = UILabel()
  let chevron = UIImageView()
  var overlayButton = Button()

  var didTapCell: CustomInteraction<FAQ>?

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

  func setup() {
    self.contentView.addSubview(self.container)
    self.container.addSubview(self.title)
    self.container.addSubview(self.chevron)
    self.container.addSubview(self.overlayButton)

    self.title.isAccessibilityElement = false
    self.overlayButton.isAccessibilityElement = true

    self.overlayButton.on(.touchUpInside) { [weak self] _ in
      guard let faq = self?.model?.faq else {
        return
      }
      self?.didTapCell?(faq)
    }
  }

  func style() {
    Self.Style.shadow(self.contentView)
    Self.Style.container(self.container)
    Self.Style.chevron(self.chevron)
    Self.Style.overlayButton(self.overlayButton)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.title)
    self.overlayButton.accessibilityLabel = model.faq.title

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .horizontally(FaqCell.containerInset)
      .vertically(7.5)

    self.chevron.pin
      .right(Self.chevronInset)
      .vCenter()
      .size(Self.chevronSize)

    self.title.pin
      .left(Self.cellInset)
      .before(of: self.chevron)
      .marginRight(Self.titleToChevron)
      .sizeToFit(.width)
      .vCenter()

    self.overlayButton.pin
      .horizontally(10)
      .vertically(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * Self.containerInset - Self.cellInset - Self.chevronSize - Self.chevronInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(width: size.width, height: titleSize.height + 70)
  }
}

private extension FaqCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.clipsToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.addShadow(.cardLightBlue)
    }

    static func chevron(_ view: UIImageView) {
      view.image = Asset.Settings.plus.image
    }

    static func overlayButton(_ button: Button) {
      button.setBackgroundColor(Palette.white.withAlphaComponent(0.4), for: .highlighted)
      button.adjustsImageWhenHighlighted = false
      button.setOverlayOpacity(0, for: .highlighted)
      button.accessibilityTraits = .button
    }

    static func title(_ label: UILabel, content: String) {
      let highlightStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.left)
      )
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
          .style("b", highlightStyle)
        ])
      )

      TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
