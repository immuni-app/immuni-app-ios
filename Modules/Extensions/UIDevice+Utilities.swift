// UIDevice+Utilities.swift
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

import UIKit

public extension UIDevice {
  /// Returns true for iPhone SE or narrower devices
  fileprivate static var isNarrowScreen: Bool {
    return UIScreen.main.bounds.width <= 320
  }

  /// Returns true for iPhone 8 or shorter devices
  fileprivate static var isShortScreen: Bool {
    return UIScreen.main.bounds.height <= 667
  }

  /// Returns true for iPad mini or larger devices
  fileprivate static var isLargeScreen: Bool {
    return UIScreen.main.bounds.width >= 768
  }

  ///
  /// Return the value associated to the current device screen.
  /// Size is checked in the order of the parameters, so if a device is both short and narrow, the short value will be returned
  /// If the size associated to the current value is nil, the value associated to normal is returned
  /// - Parameters:
  ///   - normal: the value for devices that don't match any of the other sizes
  ///   - short: the value for devices with short screen, if nil defaults on narrow, and then on normal
  ///   - narrow: the value for devices with narrow screen, if nil defaults on normal
  ///   - large: the value for devices with large screen, if nil defaults on normal
  /// - Returns:
  static func getByScreen<T>(normal: T, short: T? = nil, narrow: T? = nil, large: T? = nil) -> T {
    if let short = short, self.isShortScreen {
      return short
    } else if let narrow = narrow, self.isNarrowScreen {
      return narrow
    } else if let large = large, self.isLargeScreen {
      return large
    } else {
      return normal
    }
  }
}
