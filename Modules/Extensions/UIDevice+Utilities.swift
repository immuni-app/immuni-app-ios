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

public extension UIDevice {
  /// Parse the device name using the standard names
  var modelName: String {
    #if targetEnvironment(simulator)
      // swiftlint:disable:next force_unwrapping
      let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
    #else
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
    #endif

    switch identifier {
    case "iPod5,1": return "iPod Touch 5"
    case "iPod7,1": return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
    case "iPhone4,1": return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2": return "iPhone 5"
    case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
    case "iPhone7,2": return "iPhone 6"
    case "iPhone7,1": return "iPhone 6 Plus"
    case "iPhone8,1": return "iPhone 6s"
    case "iPhone8,2": return "iPhone 6s Plus"
    case "iPhone9,1", "iPhone9,3": return "iPhone 7"
    case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
    case "iPhone8,4": return "iPhone SE"
    case "iPhone10,1", "iPhone10,4": return "iPhone 8"
    case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6": return "iPhone X"
    case "iPhone11,2": return "iPhone XS"
    case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
    case "iPhone11,8": return "iPhone XR"
    case "iPhone12,1": return "iPhone 11"
    case "iPhone12,3": return "iPhone 11 Pro"
    case "iPhone12,5": return "iPhone 11 Pro Max"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
    case "iPad5,3", "iPad5,4": return "iPad Air 2"
    case "iPad6,11", "iPad6,12": return "iPad 5"
    case "iPad7,5", "iPad7,6": return "iPad 6"
    case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
    case "iPad5,1", "iPad5,2": return "iPad Mini 4"
    case "iPad6,3", "iPad6,4": return "iPad Pro 9.7 Inch"
    case "iPad6,7", "iPad6,8": return "iPad Pro 12.9 Inch"
    case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
    case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
    case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
    case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
    case "AppleTV5,3": return "Apple TV"
    case "AppleTV6,2": return "Apple TV 4K"
    case "AudioAccessory1,1": return "HomePod"
    default: return identifier
    }
  }
}
