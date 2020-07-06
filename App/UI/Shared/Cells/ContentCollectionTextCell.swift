// ContentCollectionTextCell.swift
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

import BonMot
import Extensions
import Foundation
import Katana
import PinLayout
import Tempura

struct ContentCollectionTextCellVM: ViewModel {
  let content: String
  let useDarkStyle: Bool

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.content != oldVM.content
  }
}

final class ContentCollectionTextCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let horizontalPadding: CGFloat = 30.0

  private var content = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.content)
  }

  func style() {}

  func update(oldModel: ContentCollectionTextCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.content(self.content, content: model.content, useDarkStyle: model.useDarkStyle)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.content.pin
      .top()
      .horizontally(Self.horizontalPadding)
      .bottom()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - 2 * Self.horizontalPadding, height: .infinity)
    let labelSize = self.content.sizeThatFits(space)
    return CGSize(width: size.width, height: labelSize.height)
  }
}

extension ContentCollectionTextCell {
  enum Style {
    static func content(_ label: UILabel, content: String, useDarkStyle: Bool) {
      let redStyle = TextStyles.pBold.byAdding([
        .color(Palette.red)
      ])

      let textStyle = TextStyles.p.byAdding(
        .color(useDarkStyle ? Palette.grayDark : Palette.grayNormal),
        .xmlRules([
          .style("b", TextStyles.pSemibold),
          .style("h", TextStyles.h4Bold),
          .style("h3", TextStyles.h3),
          .style("red", redStyle)
        ])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
