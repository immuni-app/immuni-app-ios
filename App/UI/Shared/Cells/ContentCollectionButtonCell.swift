// ContentCollectionButtonCell.swift
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

struct ContentCollectionButtonCellVM: ViewModel {
  let description: String
  let buttonTitle: String

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    if self.description != oldVM.description {
      return true
    }

    if self.buttonTitle != oldVM.buttonTitle {
      return true
    }

    return false
  }
}

final class ContentCollectionButtonCell: UICollectionViewCell, ModellableView, ReusableView {
  var userDidTapButton: Interaction?

  private static let buttonMinHeight: CGFloat = 55.0
  private static let horizontalPadding: CGFloat = 30.0
  private static let descriptionToButtonSpacer: CGFloat = 20.0

  private let actionDescription = UILabel()
  private let actionButton = ButtonWithInsets()

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
    self.contentView.addSubview(self.actionDescription)
    self.contentView.addSubview(self.actionButton)

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapButton?()
    }
  }

  func style() {}

  func update(oldModel: ContentCollectionButtonCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.description(self.actionDescription, content: model.description)
    Self.Style.button(self.actionButton, title: model.buttonTitle)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.actionButton.pin
      .bottom()
      .width(min(self.bounds.width - Self.horizontalPadding * 2, 315))
      .hCenter()
      .sizeToFit(.width)
      .minHeight(Self.buttonMinHeight)

    self.actionDescription.pin
      .above(of: self.actionButton)
      .marginBottom(Self.descriptionToButtonSpacer)
      .horizontally(Self.horizontalPadding)
      .sizeToFit(.width)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - 2 * Self.horizontalPadding, height: .infinity)
    let labelSize = self.actionDescription.sizeThatFits(space)
    let buttonSize = self.actionButton.sizeThatFits(space)
    let buttonHeight = max(buttonSize.height, ContentCollectionButtonCell.buttonMinHeight)
    return CGSize(width: size.width, height: labelSize.height + Self.descriptionToButtonSpacer + buttonHeight)
  }
}

extension ContentCollectionButtonCell {
  enum Style {
    static func description(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h4.byAdding(
          .color(Palette.grayDark),
          .alignment(.center)
        )
      )
    }

    static func button(_ button: ButtonWithInsets, title: String) {
      SharedStyle.primaryButton(button, title: title)
    }
  }
}
