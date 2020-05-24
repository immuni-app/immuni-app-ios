// PrivacySpacerCell.swift
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

struct PrivacySpacerCellVM: ViewModel {
  enum Size {
    case medium
    case small
    case big

    var cellHeight: CGFloat {
      switch self {
      case .small:
        return 15.0

      case .medium:
        return 25.0

      case .big:
        return 50
      }
    }
  }

  let size: Size
}

final class PrivacySpacerCell: UICollectionViewCell, ModellableView, ReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  func setup() {}

  func style() {}

  func update(oldModel: PrivacySpacerCellVM?) {}

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    guard let model = model else {
      return .zero
    }

    return CGSize(width: size.width, height: model.size.cellHeight)
  }
}
