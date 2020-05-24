// Optional+Utilities.swift
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

public extension Optional {
  /// Unwraps an optional or invokes the failure closure
  /// Example:
  /// ```
  ///   return someOptional ?? AppLogger.fatalError("This should never happen")
  /// ```
  static func ?? (wrapped: Self, failure: @autoclosure () -> Never) -> Wrapped {
    guard let unwrapped = wrapped else {
      failure()
    }

    return unwrapped
  }
}
