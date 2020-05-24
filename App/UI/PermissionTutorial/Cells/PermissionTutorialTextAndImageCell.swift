// PermissionTutorialTextAndImageCell.swift
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

struct PermissionTutorialTextAndImageCellVM: ViewModel {
  let textualContent: String
  let image: UIImage

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    if self.textualContent != oldVM.textualContent {
      return true
    }

    if self.image !== oldVM.image {
      return true
    }

    return false
  }
}

final class PermissionTutorialTextAndImageCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let textHorizontalPadding: CGFloat = 30.0
  private static let imageLeftPadding: CGFloat = 47.0
  private static let textImageSpacing: CGFloat = 30.0

  private var textContent = UILabel()
  private var imageContent = UIImageView()

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
    self.contentView.addSubview(self.textContent)
    self.contentView.addSubview(self.imageContent)
  }

  func style() {}

  func update(oldModel: PermissionTutorialTextAndImageCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.textualContent(self.textContent, content: model.textualContent)
    Self.Style.imageContent(self.imageContent, image: model.image)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.textContent.pin
      .right(Self.textHorizontalPadding)
      .left(Self.textHorizontalPadding)
      .sizeToFit(.width)

    self.imageContent.pin
      .below(of: self.textContent)
      .left(Self.imageLeftPadding)
      .marginTop(Self.textImageSpacing)
      .sizeToFit()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let imageSize = self.imageContent.image?.size ?? .zero

    let labelSpace = CGSize(width: size.width - Self.textHorizontalPadding * 2, height: .infinity)
    let labelSize = self.textContent.sizeThatFits(labelSpace)

    return CGSize(width: size.width, height: labelSize.height + Self.textImageSpacing + imageSize.height)
  }
}

private extension PermissionTutorialTextAndImageCell {
  enum Style {
    static func textualContent(_ label: UILabel, content: String) {
      PermissionTutorialTextCell.Style.content(label, content: content)
    }

    static func imageContent(_ imageView: UIImageView, image: UIImage) {
      imageView.image = image
    }
  }
}
