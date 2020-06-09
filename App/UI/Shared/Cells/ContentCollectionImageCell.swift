// ContentCollectionImageCell.swift
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

struct ContentCollectionImageCellVM: ViewModel {
  let content: UIImage

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.content != oldVM.content
  }
}

final class ContentCollectionImageCell: UICollectionViewCell, ModellableView, ReusableView {
  private let image = UIImageView()

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
    self.contentView.addSubview(self.image)
  }

  func style() {}

  func update(oldModel: ContentCollectionImageCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.content(self.image, content: model.content)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.image.pin.all()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let imageSize = self.image.image?.size ?? .zero

    if imageSize.width > size.width {
      let factor = size.width / imageSize.width
      return CGSize(width: size.width, height: imageSize.height * factor)
    }

    return CGSize(width: size.width, height: imageSize.height)
  }
}

extension ContentCollectionImageCell {
  enum Style {
    static func content(_ imageView: UIImageView, content: UIImage) {
      imageView.image = content
      imageView.contentMode = .scaleAspectFit
    }
  }
}
