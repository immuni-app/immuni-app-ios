// PrivacyItemCell.swift
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

struct PrivacyItemCellVM: ViewModel {
  var type: CellType

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.type != oldVM.type
  }
}

extension PrivacyItemCellVM {
  enum CellType: Equatable {
    case identity
    case people
    case location
    case secure
    case ministry
    case italy
    case deleteData

    var description: String {
      switch self {
      case .identity:
        return L10n.Privacy.Item.identity
      case .people:
        return L10n.Privacy.Item.people
      case .location:
        return L10n.Privacy.Item.location
      case .secure:
        return L10n.Privacy.Item.secure
      case .ministry:
        return L10n.Privacy.Item.ministry
      case .italy:
        return L10n.Privacy.Item.italy
      case .deleteData:
        return L10n.Privacy.Item.dataDeletion
      }
    }

    var image: UIImage {
      switch self {
      case .identity:
        return Asset.Privacy.identity.image
      case .people:
        return Asset.Privacy.people.image
      case .location:
        return Asset.Privacy.location.image
      case .secure:
        return Asset.Privacy.secure.image
      case .ministry:
        return Asset.Privacy.ministry.image
      case .italy:
        return Asset.Privacy.italy.image
      case .deleteData:
        return Asset.Privacy.deleteData.image
      }
    }
  }
}

final class PrivacyItemCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let textHorizontalPadding: CGFloat = 25.0
  private static let imageToTextPadding: CGFloat = 17.0

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

  func update(oldModel: PrivacyItemCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.textualContent(self.textContent, content: model.type.description)
    Self.Style.imageContent(self.imageContent, image: model.type.image)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let imageSize = self.imageContent.image?.size ?? .zero

    self.textContent.pin
      .right(Self.textHorizontalPadding)
      .top()
      .left(Self.textHorizontalPadding + imageSize.width + Self.imageToTextPadding)
      .sizeToFit(.width)

    self.imageContent.pin
      .before(of: self.textContent, aligned: .center)
      .left(Self.textHorizontalPadding)
      .sizeToFit()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let imageSize = self.imageContent.intrinsicContentSize

    let labelSpace = CGSize(
      width: size.width - Self.textHorizontalPadding * 2 - imageSize.width - Self.imageToTextPadding,
      height: .infinity
    )
    let labelSize = self.textContent.sizeThatFits(labelSpace)

    return CGSize(width: size.width, height: labelSize.height)
  }
}

private extension PrivacyItemCell {
  enum Style {
    static func textualContent(_ label: UILabel, content: String) {
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .xmlRules([
          .style("b", TextStyles.pSemibold)
        ])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func imageContent(_ imageView: UIImageView, image: UIImage) {
      imageView.image = image
      imageView.contentMode = .scaleAspectFit
    }
  }
}
