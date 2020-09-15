// GradientStyles.swift
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

// swiftlint:disable

// MARK: - Gradients

extension Palette {
  static var gradientBackgroundBlueOnBottom: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.075, green: 0.075, blue: 0.075, alpha: 1.00)
            : UIColor(displayP3Red: 0.99, green: 0.99, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
            : UIColor(displayP3Red: 0.98, green: 0.98, blue: 1.00, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.00),
      endPoint: CGPoint(x: 0.50, y: 1.00),
      locations: [0.00, 1.00],
      type: .linear
    )
  }

  static var gradientBackgroundBlueOnCenter: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.01, green: 0.01, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.99, green: 0.99, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.04, green: 0.03, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.96, green: 0.97, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.04, green: 0.03, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.96, green: 0.97, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.01, green: 0.01, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.99, green: 0.99, blue: 1.00, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.00),
      endPoint: CGPoint(x: 0.50, y: 1.00),
      locations: [0.00, 0.10, 0.77, 1.00],
      type: .linear
    )
  }

  static var gradientBlueOnTop: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.02, green: 0.02, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.98, green: 0.98, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.01, green: 0.01, blue: 0, alpha: 1.00)
            : UIColor(displayP3Red: 0.99, green: 0.99, blue: 1.00, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.00),
      endPoint: CGPoint(x: 0.50, y: 1.00),
      locations: [0.00, 1.00],
      type: .linear
    )
  }

  static var gradientPrimary: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.17, green: 0.16, blue: 0.5, alpha: 1.00)
            : UIColor(displayP3Red: 0.34, green: 0.32, blue: 1.00, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.205, green: 0.2, blue: 0.5, alpha: 1.00)
            : UIColor(displayP3Red: 0.41, green: 0.40, blue: 1.00, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.50),
      endPoint: CGPoint(x: 1.00, y: 0.00),
      locations: [0.00, 1.00],
      type: .linear
    )
  }

  static var gradientRed: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.05, green: 0.08, blue: 0.175, alpha: 1.00)
            : UIColor(displayP3Red: 0.95, green: 0.16, blue: 0.35, alpha: 1.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.05, green: 0.185, blue: 0.185, alpha: 1.00)
            : UIColor(displayP3Red: 0.95, green: 0.37, blue: 0.37, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.50),
      endPoint: CGPoint(x: 1.00, y: 0.00),
      locations: [0.00, 1.00],
      type: .linear
    )
  }

  static var gradientScrollOverlay: Gradient {
    return Gradient(
      colors: [
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.00, green: 0.00, blue: 0.00, alpha: 0.00)
            : UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00)
        },
        UIColor {
          $0.userInterfaceStyle == .dark
            ? UIColor(displayP3Red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
            : UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        }
      ],
      startPoint: CGPoint(x: 0.50, y: 0.00),
      endPoint: CGPoint(x: 0.50, y: 1.00),
      locations: [0.00, 1.00],
      type: .linear
    )
  }
}
