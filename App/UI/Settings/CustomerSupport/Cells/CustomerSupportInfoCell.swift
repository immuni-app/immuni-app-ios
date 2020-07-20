// CustomerSupportInfoCell.swift
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

struct CustomerSupportInfoCellVM: ViewModel, CellWithShadow {
  let info: String
  let value: String
  let shouldShowSeparator: Bool
}

class CustomerSupportInfoCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = CustomerSupportInfoCellVM

  static let horizontalInset: CGFloat = 55
  static let verticalInset: CGFloat = 15
  static let titleToValue: CGFloat = 5

  let title = UILabel()
  let value = UILabel()
  let separator = UIView()

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
    self.contentView.addSubview(self.title)
    self.contentView.addSubview(self.value)
    self.contentView.addSubview(self.separator)
  }

  func style() {
    Self.Style.container(self.contentView)
    Self.Style.separator(self.separator)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.info)
    Self.Style.value(self.value, content: model.value)

    self.isAccessibilityElement = true
    self.accessibilityLabel = model.info
    self.accessibilityValue = model.value

    self.separator.isHidden = !model.shouldShowSeparator

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.separator.pin
      .bottom()
      .horizontally(Self.horizontalInset)
      .height(1)

    self.title.pin
      .horizontally(Self.horizontalInset)
      .sizeToFit(.width)
      .top(Self.verticalInset)

    self.value.pin
      .horizontally(Self.horizontalInset)
      .sizeToFit(.width)
      .bottom(Self.verticalInset)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * Self.horizontalInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let valueSize = self.value.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(width: size.width, height: titleSize.height + valueSize.height + 2 * Self.verticalInset + Self.titleToValue)
  }
}

private extension CustomerSupportInfoCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = .clear
    }

    static func separator(_ view: UIView) {
      view.backgroundColor = Palette.grayExtraWhite
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

    static func value(_ label: UILabel, content: String) {
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
  }
}
