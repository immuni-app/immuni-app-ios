// ConfirmUploadCell.swift
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
import Foundation
import Tempura

struct ConfirmUploadCellVM: ViewModel {
  let kind: ConfirmUploadLS.DataKind

  var title: String {
    switch self.kind {
    case .result:
      return L10n.ConfirmData.Cell.Result.title
    case .proximityData:
      return L10n.ConfirmData.Cell.ProximityData.title
    case .expositionData:
      return L10n.ConfirmData.Cell.ExpositionData.title
    case .province:
      return L10n.ConfirmData.Cell.Province.title
    }
  }

  var image: UIImage {
    switch self.kind {
    case .result:
      return Asset.Settings.UploadData.result.image
    case .proximityData:
      return Asset.Settings.UploadData.proximityData.image
    case .expositionData:
      return Asset.Settings.UploadData.expositionData.image
    case .province:
      return Asset.Settings.UploadData.province.image
    }
  }
}

class ConfirmUploadCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = ConfirmUploadCellVM

  static let containerInset: CGFloat = 30
  static let cellInset: CGFloat = 25
  static let iconInset: CGFloat = 20
  static let iconSize: CGFloat = 50
  static let iconToTitle: CGFloat = 17

  let container = UIView()
  let title = UILabel()
  let icon = UIImageView()

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

  func setup() {
    self.contentView.addSubview(self.container)
    self.container.addSubview(self.title)
    self.container.addSubview(self.icon)
  }

  func style() {
    Self.Style.shadow(self.contentView)
    Self.Style.container(self.container)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.title)
    Self.Style.icon(self.icon, image: model.image)

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .horizontally(Self.containerInset)
      .vertically(7.5)

    self.icon.pin
      .left(Self.iconInset)
      .vCenter()
      .size(Self.iconSize)

    self.title.pin
      .right(Self.cellInset)
      .after(of: self.icon)
      .marginLeft(Self.iconToTitle)
      .sizeToFit(.width)
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * Self.containerInset - Self.cellInset - Self.iconSize - Self.iconToTitle - Self.iconInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let maxHeight = max(titleSize.height, Self.iconSize)
    return CGSize(width: size.width, height: maxHeight + 45)
  }
}

private extension ConfirmUploadCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.clipsToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.addShadow(.cardLightBlue)
    }

    static func icon(_ view: UIImageView, image: UIImage) {
      view.image = image
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.p.byAdding(
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
