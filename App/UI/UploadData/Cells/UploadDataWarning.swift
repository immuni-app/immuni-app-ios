// UploadDataWarning.swift
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
import Lottie
import Tempura

struct UploadDataWarningVM: ViewModel {}

// MARK: - View

class UploadDataWarningView: UIView, ModellableView {
  typealias VM = UploadDataWarningVM

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

  private let warning = UIImageView()
  private let message = UILabel()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.warning)
    self.addSubview(self.message)
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.warning(self.warning)
    Self.Style.message(self.message)
  }

  // MARK: - Update

  func update(oldModel: VM?) {}

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.warning.pin
      .sizeToFit()
      .left(38)
      .vCenter()

    self.message.pin
      .after(of: self.warning, aligned: .center)
      .right(38)
      .marginLeft(15)
      .sizeToFit(.width)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 138
    let messageSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    return CGSize(width: size.width, height: messageSize.height)
  }
}

// MARK: - Style

private extension UploadDataWarningView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = .clear
    }

    static func warning(_ view: UIImageView) {
      view.image = Asset.Settings.UploadData.alert.image
    }

    static func message(_ label: UILabel) {
      let content = L10n.UploadData.Warning.message
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.red),
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
