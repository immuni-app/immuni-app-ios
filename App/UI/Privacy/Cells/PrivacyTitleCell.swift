// PrivacyTitleCell.swift
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

struct PrivacyTitleCellVM: ViewModel {
  let content: String

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.content != oldVM.content
  }
}

final class PrivacyTitleCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let rightPadding: CGFloat = 60.0
  private static let leftPadding: CGFloat = 30.0

  private var title = UILabel()

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
    self.contentView.addSubview(self.title)
  }

  func style() {}

  func update(oldModel: PrivacyTitleCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.content)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.title.pin
      .top()
      .right(Self.rightPadding)
      .bottom()
      .left(Self.leftPadding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - Self.leftPadding - Self.rightPadding, height: .infinity)
    let labelSize = self.title.sizeThatFits(space)

    return CGSize(width: size.width, height: labelSize.height)
  }
}

private extension PrivacyTitleCell {
  enum Style {
    static func title(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h1.byAdding(
          .color(Palette.grayDark)
        )
      )
    }
  }
}
