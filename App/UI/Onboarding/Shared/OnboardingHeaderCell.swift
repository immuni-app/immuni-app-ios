// OnboardingHeaderCell.swift
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

struct OnboardingHeaderCellVM: ViewModel, Equatable {
  let title: String
  let description: String
  let actionButtonTitle: String

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    return self != oldVM
  }
}

final class OnboardingHeaderCell: UICollectionViewCell, ModellableView, ReusableView {
  static let titleToDescriptionSpacing: CGFloat = 12.0
  static let descriptionToActionSpacing: CGFloat = 6.0

  var didTapActionButton: Interaction?

  private let title = UILabel()
  private let headerDescription = UILabel()
  private var actionButton = TextButton()

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
    self.contentView.addSubview(self.headerDescription)
    self.contentView.addSubview(self.actionButton)

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapActionButton?()
    }
  }

  func style() {}

  func update(oldModel: OnboardingHeaderCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.title)
    Self.Style.description(self.headerDescription, content: model.description)
    Self.Style.actionButton(self.actionButton, content: model.actionButtonTitle)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.title.pin
      .top()
      .horizontally(OnboardingContainerAccessoryView.horizontalSpacing)
      .sizeToFit(.width)

    self.headerDescription.pin
      .below(of: self.title, aligned: .start)
      .marginTop(Self.titleToDescriptionSpacing)
      .right(OnboardingContainerAccessoryView.horizontalSpacing)
      .sizeToFit(.width)

    self.actionButton.pin
      .below(of: self.headerDescription, aligned: .start)
      .marginTop(Self.descriptionToActionSpacing)
      .right(OnboardingContainerAccessoryView.horizontalSpacing)
      .sizeToFit(.width)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - 2 * OnboardingContainerAccessoryView.horizontalSpacing, height: .infinity)
    let titleSize = self.title.sizeThatFits(space)
    let descriptionSize = self.headerDescription.sizeThatFits(space)
    let actionButtonSize = self.actionButton.sizeThatFits(space)

    return CGSize(
      width: size.width,
      height: titleSize.height + Self.titleToDescriptionSpacing + descriptionSize.height + Self
        .descriptionToActionSpacing + (!(self.model?.actionButtonTitle.isEmpty ?? true) ? actionButtonSize.height : 0)
    )
  }
}

private extension OnboardingHeaderCell {
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

    static func description(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.p.byAdding(
          .color(Palette.grayNormal)
        )
      )
    }

    static func actionButton(_ button: TextButton, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.left)
      )

      button.contentHorizontalAlignment = .left
      button.contentVerticalAlignment = .bottom
      button.attributedTitle = content.styled(with: textStyle)
    }
  }
}
