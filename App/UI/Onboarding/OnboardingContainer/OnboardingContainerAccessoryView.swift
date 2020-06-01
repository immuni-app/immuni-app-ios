// OnboardingContainerAccessoryView.swift
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
import PinLayout
import Tempura
import UIKit

struct OnboardingContainerAccessoryVM: ViewModel {
  /// Whether the view should show the back button.
  let shouldShowBackButton: Bool
  /// Whether the view should show the next button.
  let shouldShowNextButton: Bool
  /// Whether the next button is enabled.
  let shouldNextButtonBeEnabled: Bool
  /// The title of the next button, if visible.
  let nextButtonTitle: String
  /// Whether the view is scrollable and should show bottom gradient.
  let shouldShowGradient: Bool
}

final class OnboardingContainerAccessoryView: UIView, ModellableView {
  static let horizontalSpacing: CGFloat = 30.0
  static let gradientToButtonMaring: CGFloat = 50.0

  var userDidTapNext: Interaction?
  var userDidTapBack: Interaction?

  let nextButton = ButtonWithInsets()
  var backButton = ImageButton()
  private let scrollingGradient = GradientView()

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
    self.addSubview(self.scrollingGradient)
    self.addSubview(self.nextButton)
    self.addSubview(self.backButton)

    self.nextButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapNext?()
    }

    self.backButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapBack?()
    }
  }

  func style() {
    Self.Style.backButton(self.backButton)
    Self.Style.scrollingGradient(self.scrollingGradient)
  }

  func update(oldModel: OnboardingContainerAccessoryVM?) {
    guard let model = self.model else {
      return
    }

    self.backButton.alpha = model.shouldShowBackButton.cgFloat
    self.scrollingGradient.alpha = model.shouldShowGradient.cgFloat

    self.nextButton.isEnabled = model.shouldNextButtonBeEnabled
    self.nextButton.alpha = model.shouldShowNextButton.cgFloat
    Self.Style.nextButton(self.nextButton, title: model.nextButtonTitle)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.nextButton.pin
      .bottom(20 + self.safeAreaInsets.bottom)
      .right(Self.horizontalSpacing)
      .size(CGSize(width: 158, height: 55))

    self.backButton.pin
      .sizeToFit()
      .vCenter(to: self.nextButton.edge.vCenter)
      .left(Self.horizontalSpacing)

    self.scrollingGradient.pin
      .bottom()
      .left()
      .right()
      .top(to: self.nextButton.edge.top)
      .marginTop(-Self.gradientToButtonMaring)
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let nextButtonPoint = self.convert(point, to: self.nextButton)

    if self.nextButton.point(inside: nextButtonPoint, with: event) {
      return true
    }

    let backButtonPoint = self.convert(point, to: self.backButton)

    if self.backButton.point(inside: backButtonPoint, with: event) {
      return true
    }

    return false
  }
}

private extension OnboardingContainerAccessoryView {
  enum Style {
    static func nextButton(_ btn: ButtonWithInsets, title: String) {
      SharedStyle.primaryButton(btn, title: title)
    }

    static func backButton(_ btn: ImageButton) {
      SharedStyle.darkBackButton(btn)
    }

    static func scrollingGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false

      gradientView.gradient = Gradient(
        colors: [
          UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00),
          UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        ],
        startPoint: CGPoint(x: 0.50, y: 0.00),
        endPoint: CGPoint(x: 0.50, y: 1.00),
        locations: [0.00, 0.5, 1.00],
        type: .linear
      )
    }
  }
}
