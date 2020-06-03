// SuggestionsAlertCell.swift
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

struct SuggestionsAlertCellVM: ViewModel {
  let message: String
}

class SuggestionsAlertCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsAlertCellVM

  let container = UIView()
  let message = UILabel()

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
    self.container.addSubview(self.message)
  }

  func style() {
    Self.Style.container(self.container)
    Self.Style.shadow(self.contentView)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.message, content: model.message)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top()
      .bottom()
      .horizontally(SuggestionsView.cellContainerInset)

    self.message.pin
      .horizontally(SuggestionsView.cellContainerInset)
      .sizeToFit(.width)
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 4 * SuggestionsView.cellContainerInset
    let titleSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    return CGSize(width: size.width, height: titleSize.height + 2 * SuggestionsView.cellContainerInset)
  }
}

private extension SuggestionsAlertCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.purple
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.layer.masksToBounds = false
      view.addShadow(.cardPrimary)
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.white),
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
