// UIEdgeInsets+Utilities.swift
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

public extension UIEdgeInsets {
  /// Creates an edge inset with the given horizontal and vertical values.
  ///
  /// - Parameters:
  ///   - deltaX: horizontal inset
  ///   - deltaY: vertical inset
  init(deltaX: CGFloat, deltaY: CGFloat) {
    self.init(top: deltaY, left: deltaX, bottom: deltaY, right: deltaX)
  }

  /// Creates an edge inset using the given value for each edge.
  ///
  /// - Parameter inset: the value used for each edge.
  init(_ inset: CGFloat) {
    self.init(top: inset, left: inset, bottom: inset, right: inset)
  }
}

public extension UIEdgeInsets {
  /// Total horizontal inset.
  var horizontal: CGFloat {
    return self.left + self.right
  }

  /// Total vertical inset.
  var vertical: CGFloat {
    return self.top + self.bottom
  }
}
