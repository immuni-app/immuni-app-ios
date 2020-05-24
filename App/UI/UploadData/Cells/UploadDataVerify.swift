// UploadDataVerify.swift
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

struct UploadDataVerifyVM: ViewModel {
  let order: Int
  let isLoading: Bool
  let errorSecondsLeft: Int

  var hasError: Bool {
    return self.errorSecondsLeft > 0
  }

  var timeWithUnit: (Int, String) {
    switch self.errorSecondsLeft {
    case 1:
      return (1, L10n.UploadData.Verify.LoadingButton.second)
    case ...60:
      return (self.errorSecondsLeft, L10n.UploadData.Verify.LoadingButton.seconds)
    default:
      let minutesRoundedUp = 1 + self.errorSecondsLeft / 60
      return (minutesRoundedUp, L10n.UploadData.Verify.LoadingButton.minutes)
    }
  }

  var isButtonEnabled: Bool {
    return !(self.hasError || self.isLoading)
  }
}

// MARK: - View

class UploadDataVerifyView: UIView, ModellableView {
  typealias VM = UploadDataVerifyVM
  static let containerInset: CGFloat = 25
  static let labelRightMargin: CGFloat = 25
  static let labelBottomMargin: CGFloat = 10
  static let errorToButtonMargin: CGFloat = 10
  static let buttonMinHeight: CGFloat = 55

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
  let error = UILabel()
  private var actionButton = ButtonWithInsets()

  var didTapAction: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.container)
    self.container.addSubview(self.orderIndicator)
    self.container.addSubview(self.message)
    self.container.addSubview(self.error)
    self.container.addSubview(self.actionButton)

    self.container.accessibilityElements = [self.orderIndicator, self.message, self.error, self.actionButton]

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapAction?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.container(self.container)
    Self.Style.message(self.message)
    Self.Style.error(self.error)

    self.actionButton.accessibilityTraits = .updatesFrequently
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.orderLabel(self.orderIndicator, order: model.order)

    if model.hasError {
      let (time, unit) = model.timeWithUnit
      SharedStyle.primaryButton(self.actionButton, title: L10n.UploadData.Verify.loadingButton(time, unit))
    } else {
      SharedStyle.primaryButton(self.actionButton, title: L10n.UploadData.Verify.button)
    }

    self.actionButton.isEnabled = model.isButtonEnabled
    self.error.alpha = model.hasError.cgFloat

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

    self.error.pin
      .right(Self.labelRightMargin)
      .left(UploadDataView.orderLeftMargin)
      .sizeToFit(.width)
      .below(of: self.message)
      .marginTop(Self.labelBottomMargin)

    self.actionButton.pin
      .right(Self.labelRightMargin)
      .left(UploadDataView.orderLeftMargin)
      .sizeToFit(.width)
      .minHeight(Self.buttonMinHeight)
      .bottom(Self.containerInset)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - UploadDataView.orderLeftMargin - UploadDataVerifyView.labelRightMargin
      - 2 * UploadDataVerifyView.containerInset
    let messageSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    let buttonSize = self.actionButton.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    let buttonHeight = max(buttonSize.height, UploadDataVerifyView.buttonMinHeight)
    if self.model?.hasError ?? false {
      let errorSize = self.error.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
      return CGSize(
        width: size.width,
        height: messageSize.height + errorSize.height + buttonHeight + 2 * UploadDataVerifyView.containerInset
          + UploadDataVerifyView.labelBottomMargin + UploadDataVerifyView.errorToButtonMargin
      )
    } else {
      return CGSize(
        width: size.width,
        height: messageSize.height + buttonHeight + 2 * UploadDataVerifyView.containerInset
          + UploadDataVerifyView.labelBottomMargin
      )
    }
  }
}

// MARK: - Style

private extension UploadDataVerifyView {
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
      let content = L10n.UploadData.Verify.message
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

    static func error(_ label: UILabel) {
      let content = L10n.UploadData.Verify.error
      let textStyle = TextStyles.sSemibold.byAdding(
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
