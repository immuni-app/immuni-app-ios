// UploadDataMessage.swift
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

struct UploadDataMessageVM: ViewModel {
  let order: Int
}

// MARK: - View

class UploadDataMessageView: UIView, ModellableView {
  typealias VM = UploadDataMessageVM
  static let containerInset: CGFloat = 25
  static let labelRightMargin: CGFloat = 25

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

  private let container = UIView()
  private let orderIndicator = UILabel()
  private let message = UILabel()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.container)
    self.container.addSubview(self.orderIndicator)
    self.container.addSubview(self.message)

    self.container.accessibilityElements = [self.orderIndicator, self.message]
  }

  // MARK: - Style

  func style() {
    Self.Style.container(self.container)
    Self.Style.message(self.message)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
    Self.Style.orderLabel(self.orderIndicator, order: model.order)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .vertically()
      .horizontally(25)

    self.message.pin
      .right(Self.labelRightMargin)
      .left(UploadDataView.orderLeftMargin)
      .top(Self.containerInset)
      .sizeToFit(.width)

    self.orderIndicator.pin
      .left()
      .width(UploadDataView.orderLeftMargin)
      .sizeToFit(.width)
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - UploadDataView.orderLeftMargin - UploadDataCodeView.labelRightMargin
      - 2 * UploadDataCodeView.containerInset
    let messageSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    return CGSize(
      width: size.width,
      height: messageSize.height + 2 * UploadDataCodeView.containerInset
    )
  }
}

// MARK: - Style

private extension UploadDataMessageView {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.addShadow(.cardLightBlue)
    }

    static func orderLabel(_ label: UILabel, order: Int) {
      let content = "\(order)"
      let textStyle = TextStyles.h3.byAdding(
        .color(Palette.primary),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func message(_ label: UILabel) {
      let content = L10n.UploadData.WaitOperator.message
      let textStyle = TextStyles.pSemibold.byAdding(
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
