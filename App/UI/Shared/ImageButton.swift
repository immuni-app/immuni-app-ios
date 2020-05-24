// ImageButton.swift
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

/// Image Button is a subclass of `UIButton` that implement an internal Bending Spoons standard.
/// This element is meant to be used as a button without background and only with a single, central image.
///
/// The default implementation reflects the standard we established with designers but you can customise some properties
/// such as the opacity of the title when the button is highlighted, disabled or even in the normal state.
///
/// The usage is pretty straighforward, you just have to assign the `image` property.
///
/// ### Size Management
///
/// The button leverages the UIKit system for intrinsic sizes. In the layout of your view
/// you can use `sizeThatFits` (or PinLayout's `fitSize`) to properly resize the button around
/// the image.
///
/// If you want to add extra space around the image (for instance, to have decent hit insets) look at UIButton's
/// `contentEdgeInsets` property
open class ImageButton: UIButton {
  /// Dictionary that stores the button opacities
  private var opacities: [UInt: CGFloat] = [
    UIControl.State.normal.rawValue: 1.0,
    UIControl.State.highlighted.rawValue: 0.6,
    UIControl.State.disabled.rawValue: 0.4
  ]

  /**
   Set the image of the button.
   By setting this property normal, highlighted and disabled state are changed
   according to the opacities specified in the proper variables
   */
  public var image: UIImage? {
    didSet {
      self.update()
    }
  }

  override open var isHighlighted: Bool {
    didSet {
      self.update()
    }
  }

  override open var isEnabled: Bool {
    didSet {
      self.update()
    }
  }

  /// Minimum tappable area's side.
  /// According to Human Interface Guidelines the app should provide a minimum tappable area of 44pt x 44pt for all controls.
  public var minimumHitAreaSize: CGFloat = 44

  override public init(frame: CGRect) {
    self.image = nil
    super.init(frame: frame)
    self.setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    self.image = nil
    super.init(coder: aDecoder)
    self.setup()
  }

  // MARK: Public methods

  public func setImageOpacity(_ opacity: CGFloat, for state: UIControl.State) {
    self.opacities[state.rawValue] = opacity
    self.update()
  }

  // MARK: Setup

  private func setup() {
    self.backgroundColor = .clear
  }

  // MARK: Update

  private func update() {
    self.setImage(self.image, for: .normal)
    self.imageView?.alpha = self.opacities[self.state.rawValue] ?? 1.0
  }

  // MARK: Accessibility

  override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let verticalInset = max(self.minimumHitAreaSize - self.bounds.height, 0)
    let horizontalInset = max(self.minimumHitAreaSize - self.bounds.width, 0)

    return self.bounds.insetBy(dx: -horizontalInset / 2, dy: -verticalInset / 2).contains(point)
  }

  override open var intrinsicContentSize: CGSize {
    return self.image?.size ?? .zero
  }
}
