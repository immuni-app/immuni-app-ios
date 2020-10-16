// OnboardingCheckCell.swift
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

// MARK: - Model

struct OnboardingCheckCellVM: ViewModel, Hashable {
  let title: String
  let isSelected: Bool
  let isDisable: Bool

  var accessibilityTraits: UIAccessibilityTraits {
    if self.isSelected {
      return [.button, .selected]
    } else {
      return .button
    }
  }
}

// MARK: - View

class OnboardingCheckCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let titleToCheckmarkMargin: CGFloat = 20

  // we cannot rely on the proper asset size, as the checked one
  // is bigger because of the shadow. The keep it visually consistent, we need
  // to use a fixed size
  private static let checkmarkSize: CGFloat = 25.0

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

  let checkmark = UIImageView()
  let title = UILabel()

  // MARK: Setup

  func setup() {
    self.contentView.addSubview(self.checkmark)
    self.contentView.addSubview(self.title)

    self.isAccessibilityElement = true
  }

  // MARK: Style

  func style() {}

  // MARK: Update

  func update(oldModel: OnboardingCheckCellVM?) {
    guard let model = self.model else {
      self.checkmark.image = nil
      self.title.attributedText = nil
      return
    }

    self.accessibilityLabel = model.title
    self.accessibilityTraits = model.accessibilityTraits

    Self.Style.checkmark(self.checkmark, isSelected: model.isSelected, isDisable: model.isDisable)
    Self.Style.title(self.title, content: model.title)
    self.setNeedsLayout()
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let titleSpacing = OnboardingContainerAccessoryView.horizontalSpacing + Self.checkmarkSize + Self.titleToCheckmarkMargin

    self.title.pin
      .left(titleSpacing)
      .right(OnboardingContainerAccessoryView.horizontalSpacing)
      .sizeToFit(.width)
      .vCenter()

    self.checkmark.pin
      .sizeToFit()
      .left()
      .before(of: self.title, aligned: .center)
      .justify(.center)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let availableWidth = size.width - 2 * OnboardingContainerAccessoryView.horizontalSpacing - Self
      .titleToCheckmarkMargin - Self.checkmarkSize

    let titleSize = self.title.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.infinity))

    return CGSize(
      width: size.width,
      height: titleSize.height + 25
    )
  }
}

// MARK: - Style

private extension OnboardingCheckCell {
  enum Style {
    static func checkmark(_ view: UIImageView, isSelected: Bool, isDisable: Bool) {
      if isSelected && !isDisable {
        view.image = Asset.Privacy.checkboxSelected.image
      } else if isSelected && isDisable {
        view.image = Asset.Privacy.checkboxSelectedDisable.image
      } else {
        view.image = Asset.Privacy.checkbox.image
      }
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.h4.byAdding(
        .color(Palette.grayDark),
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
