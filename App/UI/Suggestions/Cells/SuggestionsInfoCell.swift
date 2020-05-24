// SuggestionsInfoCell.swift
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
import Tempura

struct SuggestionsInfoCellVM: ViewModel {
  let title: String
  let subtitle: String
}

class SuggestionsInfoCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsInfoCellVM

  static let iconSize: CGFloat = 25
  static let titleMargin: CGFloat = 15

  let container = UIView()
  let icon = UIImageView()
  let title = UILabel()
  let subtitle = UILabel()

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
    self.container.addSubview(self.icon)
    self.container.addSubview(self.title)
    self.container.addSubview(self.subtitle)
  }

  func style() {
    Self.Style.container(self.container)
    Self.Style.shadow(self.contentView)
    Self.Style.info(self.icon)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.title)
    Self.Style.subtitle(self.subtitle, content: model.subtitle)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top()
      .bottom()
      .horizontally(SuggestionsView.cellContainerInset)

    self.title.pin
      .left(SuggestionsView.cellContainerInset + Self.iconSize + Self.titleMargin)
      .right(SuggestionsView.cellContainerInset)
      .sizeToFit(.width)
      .top(SuggestionsView.cellContainerInset)

    self.icon.pin
      .size(Self.iconSize)
      .left(SuggestionsView.cellContainerInset)
      .vCenter(to: self.title.edge.vCenter)

    self.subtitle.pin
      .horizontally(SuggestionsView.cellContainerInset)
      .sizeToFit(.width)
      .bottom(SuggestionsView.cellContainerInset)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let titleWidth = size.width - 4 * SuggestionsView.cellContainerInset - SuggestionsInfoCell.iconSize
      - SuggestionsInfoCell.titleMargin
    let subtitleWidth = size.width - 4 * SuggestionsView.cellContainerInset
    let titleSize = self.title.sizeThatFits(CGSize(width: titleWidth, height: CGFloat.infinity))
    let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: subtitleWidth, height: CGFloat.infinity))

    return CGSize(
      width: size.width,
      height: titleSize.height + subtitleSize.height + 2 * SuggestionsView.cellContainerInset + SuggestionsInfoCell.titleMargin
    )
  }
}

private extension SuggestionsInfoCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.layer.masksToBounds = false
      view.addShadow(.cardLightBlue)
    }

    static func info(_ view: UIImageView) {
      view.image = Asset.Common.iconInfo.image
      view.contentMode = .scaleAspectFit
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func subtitle(_ label: UILabel, content: String) {
      let textStyle = TextStyles.s.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
