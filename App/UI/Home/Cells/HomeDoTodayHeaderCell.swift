// HomeInfoHeaderCell.swift
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

struct HomeDoTodayHeaderCellVM: ViewModel {}

class HomeDoTodayHeaderCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeDoTodayHeaderCellVM

  let title = UILabel()

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
  }

  func style() {
    Self.Style.container(self.contentView)
    Self.Style.title(self.title)
  }

  func update(oldModel: VM?) {}

  override func layoutSubviews() {
    super.layoutSubviews()

    self.title.pin
      .horizontally(HomeView.cellHorizontalInset)
      .sizeToFit(.width)
      .bottom(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * HomeView.cellHorizontalInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(width: size.width, height: titleSize.height + 15)
  }
}

private extension HomeDoTodayHeaderCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = .clear
    }

    static func title(_ label: UILabel) {
      let content = "Cosa vuoi fare oggi?"

      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )

      TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
