// SharedStyles.swift
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
import UIKit

enum SharedStyle {
  static let cardCornerRadius: CGFloat = 30

  static func closeButton(_ button: ImageButton, color: UIColor = Palette.grayDark) {
    button.image = Asset.Common.closeButton.image
    button.tintColor = color

    button.isAccessibilityElement = true
    button.accessibilityLabel = L10n.Accessibility.close
  }

  static func completeButton(_ button: ImageButton, color: UIColor = Palette.purple) {
    button.image = Asset.Common.checkIcon.image
    button.tintColor = color

    button.isAccessibilityElement = true
    button.accessibilityLabel = L10n.Accessibility.close
  }

  static func backButton(_ button: ImageButton) {
    button.image = Asset.Common.backButton.image

    button.isAccessibilityElement = true
    button.accessibilityLabel = L10n.Accessibility.back
  }

  static func darkBackButton(_ button: ImageButton) {
    button.image = Asset.Common.darkBackButton.image

    button.isAccessibilityElement = true
    button.accessibilityLabel = L10n.Accessibility.back
  }

  static func navigationBackButton(_ button: ImageButton) {
    button.image = Asset.Common.navigationBack.image

    button.isAccessibilityElement = true
    button.accessibilityLabel = L10n.Accessibility.back
  }

  static func primaryButton(
    _ button: ButtonWithInsets,
    title: String?,
    icon: UIImage? = nil,
    spacing: CGFloat = 15,
    tintColor: UIColor = Palette.white,
    backgroundColor: UIColor = Palette.primary,
    insets: UIEdgeInsets = .primaryButtonInsets,
    cornerRadius: CGFloat = 28,
    shadow: UIView.Shadow = .cardPrimary
  ) {
    let textStyle = TextStyles.pSemibold.byAdding([
      .color(tintColor),
      .alignment(.center)
    ])

    button.setBackgroundColor(backgroundColor, for: .normal)
    button.setAttributedTitle(title?.styled(with: textStyle), for: .normal)
    button.setImage(icon, for: .normal)
    button.tintColor = tintColor
    button.insets = insets
    button.layer.cornerRadius = cornerRadius
    button.titleLabel?.numberOfLines = 0
    button.addShadow(shadow)

    if title != nil && icon != nil {
      button.titleEdgeInsets = .init(top: 0, left: insets.left + spacing / 2, bottom: 0, right: insets.right)
      button.imageEdgeInsets = .init(top: 0, left: insets.left, bottom: 0, right: insets.right + spacing / 2)
    } else {
      button.titleEdgeInsets = insets
    }
  }
}

extension UIEdgeInsets {
  static var primaryButtonInsets: UIEdgeInsets {
    UIDevice.getByScreen(normal: .init(deltaX: 25, deltaY: 15), narrow: .init(deltaX: 15, deltaY: 15))
  }
}

extension UIView {
  enum Shadow {
    case none
    case cardLightBlue
    case cardOrange
    case cardPrimary
    case cardPurple
    case cardRed
    case grayDark
    case headerLightBlue
    case tabbar
    case tabbarIcon
    case textfieldFocus
  }

  func addShadow(_ shadow: Shadow) {
    switch shadow {
    case .none:
      self.layer.shadowOpacity = 0
    case .cardLightBlue:
      self.layer.shadowColor = UIColor(displayP3Red: 0.341, green: 0.318, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.1
      self.layer.shadowRadius = 10
      self.layer.shadowOffset = CGSize(width: 0, height: 3)
    case .cardOrange:
      self.layer.shadowColor = UIColor(displayP3Red: 0.949, green: 0.396, blue: 0.161, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 15
      self.layer.shadowOffset = CGSize(width: 0, height: 4)
    case .cardPrimary:
      self.layer.shadowColor = UIColor(displayP3Red: 0.341, green: 0.318, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.4
      self.layer.shadowRadius = 12
      self.layer.shadowOffset = CGSize(width: 0, height: 0)
    case .cardPurple:
      self.layer.shadowColor = UIColor(displayP3Red: 0.404, green: 0.353, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 20
      self.layer.shadowOffset = CGSize(width: 0, height: 0)
    case .cardRed:
      self.layer.shadowColor = UIColor(displayP3Red: 0.949, green: 0.161, blue: 0.349, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 15
      self.layer.shadowOffset = CGSize(width: 0, height: 4)
    case .grayDark:
      self.layer.shadowColor = UIColor(displayP3Red: 0.184, green: 0.31, blue: 0.459, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 15
      self.layer.shadowOffset = CGSize(width: 0, height: 0)
    case .headerLightBlue:
      self.layer.shadowColor = UIColor(displayP3Red: 0.217, green: 0.436, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.1
      self.layer.shadowRadius = 18
      self.layer.shadowOffset = CGSize(width: 0, height: 3)
    case .tabbar:
      self.layer.shadowColor = UIColor(displayP3Red: 0.361, green: 0.35, blue: 0.867, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.05
      self.layer.shadowRadius = 20
      self.layer.shadowOffset = CGSize(width: 0, height: -20)
    case .tabbarIcon:
      self.layer.shadowColor = UIColor(displayP3Red: 0.341, green: 0.318, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.2
      self.layer.shadowRadius = 6
      self.layer.shadowOffset = CGSize(width: 2, height: 3)
    case .textfieldFocus:
      self.layer.shadowColor = UIColor(displayP3Red: 0.489, green: 0.471, blue: 1, alpha: 1).cgColor
      self.layer.shadowOpacity = 0.25
      self.layer.shadowRadius = 15
      self.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
  }
}

extension UIView {
  /// Helper to set accessiblity label and enable the accessibility feature.
  func setAccessibilityLabel(_ text: String) {
    self.isAccessibilityElement = true
    self.accessibilityLabel = text
  }
}
