// LoadingView.swift
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

struct LoadingVM: ViewModelWithLocalState {
  /// The message to be shown in the loader while the loading occurs.
  let message: String?

  var shouldShowMessage: Bool {
    return self.message != nil
  }
}

extension LoadingVM {
  init?(state: AppState?, localState: LoadingLS) {
    self.message = localState.message
  }
}

// MARK: - View

class LoadingView: UIView, ViewControllerModellableView {
  typealias VM = LoadingVM

  private static let spinnerSize: CGFloat = 50
  private static let messageToSpinnerMargin: CGFloat = 11
  private static let verticalInset: CGFloat = 25
  private static let horizontalInset: CGFloat = 11

  private let background = UIView()
  private let spinnerBackground = UIView()
  private let spinner = AnimationView()
  private let message = UILabel()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.background)
    self.addSubview(self.spinnerBackground)
    self.spinnerBackground.addSubview(self.spinner)
    self.spinnerBackground.addSubview(self.message)
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self.background)
    Self.Style.spinnerBackground(self.spinnerBackground)
    Self.Style.spinner(self.spinner)

    self.spinnerBackground.alpha = 0
    self.background.alpha = 0
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.message(self.message, content: model.message)
    self.setNeedsLayout()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let shouldShowMessage = self.model?.shouldShowMessage ?? false

    self.background.pin.all()

    self.spinner.pin
      .size(Self.spinnerSize).top(Self.verticalInset)

    let maxMessageSize = self.bounds.width * 0.8
    let messageSize = shouldShowMessage
      ? self.message.sizeThatFits(CGSize(width: maxMessageSize, height: maxMessageSize))
      : .zero

    let messageToSpinnerMargin = shouldShowMessage
      ? Self.messageToSpinnerMargin
      : .zero

    self.message.pin
      .size(messageSize)
      .below(of: self.spinner)
      .marginTop(messageToSpinnerMargin)

    let maxSize = max(
      Self.spinnerSize + messageSize.height + messageToSpinnerMargin + 2 * Self.verticalInset,
      messageSize.width + 2 * Self.horizontalInset
    )
    self.spinnerBackground.pin
      .center()
      .size(maxSize)

    self.spinner.pin
      .hCenter()

    self.message.pin
      .hCenter()
  }

  func showLoader() {
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      options: [.beginFromCurrentState],
      animations: {
        self.background.alpha = 1
      },
      completion: nil
    )
  }

  func playAnimationIfNeeded() {
    UIView.animate(
      withDuration: 0.2,
      delay: 0.3,
      options: [.beginFromCurrentState, .allowAnimatedContent],
      animations: {
        self.spinnerBackground.alpha = 1
      },
      completion: nil
    )

    self.spinner.playIfPossible()
  }
}

// MARK: - Style

private extension LoadingView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = UIColor(displayP3Red: 0.25, green: 0.29, blue: 0.45, alpha: 0.8)
    }

    static func spinnerBackground(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = 20
    }

    static func spinner(_ spinner: AnimationView) {
      spinner.animation = AnimationAsset.loader.animation
      spinner.loopMode = .loop
    }

    static func message(_ label: UILabel, content: String?) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content ?? "",
        style: textStyle
      )
    }
  }
}
