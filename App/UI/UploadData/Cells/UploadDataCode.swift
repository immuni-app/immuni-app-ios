// UploadDataCode.swift
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
import Models
import Tempura

struct UploadDataCodeVM: ViewModel {
  let order: Int
  let code: OTP

  var codeParts: [String] {
    return self.code.codeParts
  }
}

// MARK: - View

class UploadDataCodeView: UIView, ModellableView {
  typealias VM = UploadDataCodeVM
  static let containerInset: CGFloat = 25
  static let labelRightMargin: CGFloat = 25
  static let labelToCode: CGFloat = 5

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

  // MARK: - Setup

  private let container = UIView()
  private let orderIndicator = UILabel()
  private let message = UILabel()
  private let code = UILabel()

  func setup() {
    self.addSubview(self.container)
    self.container.addSubview(self.orderIndicator)
    self.container.addSubview(self.message)
    self.container.addSubview(self.code)

    self.container.accessibilityElements = [self.orderIndicator, self.message, self.code]
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

    Self.Style.code(self.code, codeParts: model.codeParts)
    Self.Style.orderLabel(self.orderIndicator, order: model.order)

    // best effort solution to slow down as much as possible the Speech recognition of the code.
    let letters: [Character] = model.codeParts.joined(separator: ".").flatMap { [$0, " "] }
    self.code.accessibilityLabel = String(letters)
    self.code.accessibilityTextualContext = .sourceCode

    self.setNeedsLayout()
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

    self.code.pin
      .right(Self.labelRightMargin)
      .left(UploadDataView.orderLeftMargin)
      .sizeToFit(.width)
      .below(of: self.message)
      .marginTop(Self.labelToCode)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - UploadDataView.orderLeftMargin - UploadDataCodeView.labelRightMargin
      - 2 * UploadDataCodeView.containerInset
    let messageSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    let codeSize = self.code.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    return CGSize(
      width: size.width,
      height: messageSize.height + codeSize.height + 2 * UploadDataCodeView.containerInset + UploadDataCodeView.labelToCode
    )
  }
}

// MARK: - Style

private extension UploadDataCodeView {
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
      let content = L10n.UploadData.Code.message
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

    static func code(_ label: UILabel, codeParts: [String]) {
      let baseStyle = UIDevice.getByScreen(normal: TextStyles.alphanumericCode, narrow: TextStyles.alphanumericCodeSmall)
      let textStyle = baseStyle.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .lineBreakMode(.byTruncatingTail)
      )

      let composable: [Composable] = codeParts.flatMap { ([$0.styled(with: textStyle), Special.enSpace]) as [Composable] }

      label.numberOfLines = 0
      label.attributedText = NSAttributedString.composed(of: composable.dropLast()).adapted()
    }
  }
}
