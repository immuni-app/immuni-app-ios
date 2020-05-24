// SuggestionSeparatorCell.swift
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
import Tempura

struct SuggestionsSeparatorVM: ViewModel {}

final class SuggestionsSeparator: UICollectionViewCell, ModellableView, ReusableView {
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

  private let image = UIImageView()

  func setup() {
    self.contentView.addSubview(self.image)
  }

  func style() {
    Self.Style.content(self.image)
  }

  func update(oldModel: SuggestionsSeparatorVM?) {}

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

extension SuggestionsSeparator {
  enum Style {
    static func content(_ imageView: UIImageView) {
      imageView.image = Asset.Common.separator.image
      imageView.contentMode = .scaleAspectFit
    }
  }
}
