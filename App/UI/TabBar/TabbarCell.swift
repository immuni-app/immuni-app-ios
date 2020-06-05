// TabbarCell.swift
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

import Foundation
import Tempura

// MARK: - Model

struct TabbarCellVM: ViewModel, Hashable {
  let tab: TabbarVM.Tab
  let isSelected: Bool

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.tab)
  }

  var accessibilityTraits: UIAccessibilityTraits {
    return self.isSelected ? .selected : []
  }
}

// MARK: - View

class TabbarCell: UICollectionViewCell, ModellableView {
  static let identifierForReuse: String = "\(TabbarCell.self)"
  typealias VM = TabbarCellVM

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

  let icon = UIImageView()
  let title = UILabel()

  // MARK: Setup

  func setup() {
    self.addSubview(self.icon)
    self.addSubview(self.title)
  }

  // MARK: Style

  func style() {
    Self.Style.container(self.contentView)
  }

  // MARK: Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    self.isAccessibilityElement = true
    self.accessibilityLabel = model.tab.title
    self.accessibilityTraits = model.accessibilityTraits

    self.icon.image = model.isSelected ? model.tab.selectedImage : model.tab.deselectedImage
    Self.Style.iconShadow(self.icon, isSelected: model.isSelected)
    Self.Style.title(self.title, content: model.tab.title, isSelected: model.isSelected)
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.icon.pin
      .size(40)
      .vCenter(-7)
      .hCenter()

    self.title.pin
      .horizontally(5)
      .sizeToFit(.width)
      .below(of: self.icon)
  }
}

// MARK: - Style

private extension TabbarCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = UIColor.clear
    }

    static func iconShadow(_ view: UIImageView, isSelected: Bool) {
      view.layer.masksToBounds = false
      view.addShadow(isSelected ? .tabbarIcon : .none)
    }

    static func title(_ label: UILabel, content: String, isSelected: Bool) {
      let textStyle = TextStyles.sSemibold.byAdding(
        .color(isSelected ? Palette.primary : Palette.grayPurple),
        .alignment(.center)
      )

      TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: textStyle,
        numberOfLines: 1
      )
    }
  }
}
