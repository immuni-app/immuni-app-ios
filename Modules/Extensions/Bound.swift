// Bound.swift
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

/// An interval that can clamp a value to its bounds
public protocol ClampingInterval {
  associatedtype Bound: Comparable

  /// Clamps a value to the interval bounds
  ///
  /// ```swift
  /// // Examples
  /// (0...10).clamp(14) // 10
  /// (0...10).clamp(5)  // 5
  /// (10...).clamp(-1)  // 10
  /// ```
  func clamp(_ value: Bound) -> Bound
}

extension ClosedRange: ClampingInterval {
  public func clamp(_ value: Bound) -> Bound {
    if value > self.upperBound { return upperBound }
    if value < self.lowerBound { return lowerBound }
    return value
  }
}

extension PartialRangeThrough: ClampingInterval {
  public func clamp(_ value: Bound) -> Bound {
    if value > self.upperBound { return self.upperBound }
    return value
  }
}

extension PartialRangeFrom: ClampingInterval {
  public func clamp(_ value: Bound) -> Bound {
    if value < self.lowerBound { return self.lowerBound }
    return value
  }
}

public extension Comparable {
  /// Bounds a value within an interval.
  ///
  /// ```swift
  /// // Example
  /// 14.bounded(to: 0...10) // 10
  /// ```
  func bounded<Interval: ClampingInterval>(to interval: Interval) -> Self where Interval.Bound == Self {
    return interval.clamp(self)
  }
}

public extension Comparable {
  /// Bounds a value between a min and a max
  func bounded(min: Self, max: Self) -> Self {
    return self.bounded(to: min ... max)
  }

  /// Bounds a value to a lower bound
  func bounded(min: Self) -> Self {
    return self.bounded(to: min...)
  }

  /// Bounds a value to an upper bound
  func bounded(max: Self) -> Self {
    return self.bounded(to: ...max)
  }
}
