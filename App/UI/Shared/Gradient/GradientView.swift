// GradientView.swift
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

/// Gradient View is a subclass of `UIView` that implements a layer with a gradient.
/// By default the gradient is a vertical gradient with the first color on top and last on the bottom part of the view.
/// Besides these additions, this element is an `UIView` and you should refer to the Apple's documentation for its usage.
///
/// ### Colors
/// the colors to use in the gradient. Note that order matters
///
/// ### Locations
/// the location of each gradient stop.
///
/// ### StartPoint
/// the position where the gradient color sequence starts
///
/// ### EndPoint
/// the position where the gradient color sequence ends
open class GradientView: UIView {
  public var gradient = Gradient() {
    didSet {
      guard self.gradient != oldValue else { return }
      self.update()
    }
  }

  lazy var gradientLayer: CAGradientLayer = {
    CAGradientLayer()
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  // MARK: Setup

  private func setup() {
    self.layer.addSublayer(self.gradientLayer)
  }

  // MARK: Update

  func update() {
    self.gradient.apply(to: self.gradientLayer)
  }

  override open func layoutSubviews() {
    super.layoutSubviews()

    CATransaction.withDisabledActions {
      self.gradientLayer.frame = self.bounds
    }
  }
}
