// Gradient.swift
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

/// Wrapper around the information needed to define a gradient.
public struct Gradient: Equatable {
  /// Type of the gradient used to map `CAGradientLayerType`s
  public enum GradientType: Int {
    case linear
    case radial
    case conic

    var gradientLayerType: CAGradientLayerType? {
      switch self {
      case .linear:
        return .axial
      case .radial:
        return .radial
      case .conic:
        return .conic
      }
    }
  }

  /// Points where a gradient can start/end
  public enum Point {
    case custom(CGPoint)
    case top, bottom, left, right
    case topLeft, topRight, bottomLeft, bottomRight
    case center

    fileprivate var point: CGPoint {
      switch self {
      case .center:
        return CGPoint(x: 0.5, y: 0.5)

      case .top:
        return CGPoint(x: 0.5, y: 0.0)

      case .bottom:
        return CGPoint(x: 0.5, y: 1.0)

      case .left:
        return CGPoint(x: 0.0, y: 0.5)

      case .right:
        return CGPoint(x: 1.0, y: 0.5)

      case .topLeft:
        return CGPoint(x: 0.0, y: 0.0)

      case .topRight:
        return CGPoint(x: 1.0, y: 0.0)

      case .bottomLeft:
        return CGPoint(x: 0.0, y: 1.0)

      case .bottomRight:
        return CGPoint(x: 1.0, y: 1.0)

      case .custom(let value):
        return value
      }
    }
  }

  /// Colors to use in the gradient.
  /// Note that order matters
  public var colors: [UIColor]
  /// Position where the gradient color sequence starts
  public var startPoint: CGPoint
  /// Position where the gradient color sequence ends
  public var endPoint: CGPoint
  /// Location of each color stop as a value in the range [0,1].
  /// The values must be monotonically increasing.
  public var locations: [CGFloat]
  /// Type of the gradient
  public var type: GradientType

  /**
   Creates an instance of `Gradient` with the given values

   - parameter colors: the colors to use in the gradient. Note that order matters
   - parameter startPoint: the position where the gradient color sequence starts
   - parameter endPoint: the position where the gradient color sequence ends
   - parameter locations: location of each color stop as a value in the range [0,1]
   - parameter type: type of the gradient, see GradientType
   */
  public init(
    colors: [UIColor],
    startPoint: CGPoint,
    endPoint: CGPoint,
    locations: [CGFloat] = [],
    type: GradientType = .linear
  ) {
    self.colors = colors
    self.startPoint = startPoint
    self.endPoint = endPoint
    self.locations = locations
    self.type = type
  }

  public init(
    colors: [UIColor],
    startPoint: Point,
    endPoint: Point,
    locations: [CGFloat] = [],
    type: GradientType = .linear
  ) {
    self.init(colors: colors, startPoint: startPoint.point, endPoint: endPoint.point, locations: locations, type: type)
  }

  /// Creates a linear black/clear gradient from top to bottom
  public init() {
    self.init(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
  }

  /// Flips the gradient inverting start and end points
  public var flipped: Gradient {
    return Gradient(
      colors: self.colors,
      startPoint: self.endPoint,
      endPoint: self.startPoint,
      locations: self.locations,
      type: self.type
    )
  }

  /// Inverts the gradient's colors
  public var inverted: Gradient {
    return Gradient(
      colors: self.colors.reversed(),
      startPoint: self.startPoint,
      endPoint: self.endPoint,
      locations: self.locations,
      type: self.type
    )
  }

  /// Tries to apply gradient to the given layer
  /// If it cannot apply it, the first color of the gradient is set as solid background color
  public func apply(to layer: CAGradientLayer) {
    guard let gradientLayerType = self.type.gradientLayerType else {
      layer.backgroundColor = self.colors.first?.cgColor
      return
    }
    layer.colors = self.colors.map { $0.cgColor }
    layer.startPoint = self.startPoint
    layer.endPoint = self.endPoint
    layer.type = gradientLayerType

    if !self.locations.isEmpty {
      layer.locations = self.locations as [NSNumber]?
    }
  }
}

public extension Gradient {
  /// A completely transparent gradient
  static let clear = Gradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
}
