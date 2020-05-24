// ColorStyles.swift
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

// swiftlint:disable all

// Namespace for app colors
enum Palette {}

// MARK: - Solid colors

extension Palette {
  static var grayDark: UIColor {
    return UIColor(named: "GrayDark")!
  }

  static var grayExtraWhite: UIColor {
    return UIColor(named: "GrayExtraWhite")!
  }

  static var grayNormal: UIColor {
    return UIColor(named: "GrayNormal")!
  }

  static var grayPurple: UIColor {
    return UIColor(named: "GrayPurple")!
  }

  static var grayWhite: UIColor {
    return UIColor(named: "GrayWhite")!
  }

  static var primary: UIColor {
    return UIColor(named: "Primary")!
  }

  static var purple: UIColor {
    return UIColor(named: "Purple")!
  }

  static var red: UIColor {
    return UIColor(named: "Red")!
  }

  static var redLight: UIColor {
    return UIColor(named: "RedLight")!
  }

  static var white: UIColor {
    return UIColor(named: "White")!
  }
}
