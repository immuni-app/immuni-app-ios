// Date+Formatting.swift
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

public extension Date {
  /// Formatter for UTC ISO
  private static let utcIsoFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
  }()

  /// Returns this date formatted in `yyyy-MM-dd` in UTC
  var utcIsoString: String {
    return Self.utcIsoFormatter.string(from: self)
  }

  /// Instantiates a date from a `yyyy-MM-dd` day in UTC
  init?(utcIsoString: String) {
    guard let date = Self.utcIsoFormatter.date(from: utcIsoString) else {
      return nil
    }

    self = date
  }

  /// Formatter for the full date with milliseconds
  private static let fullDateTimeWithMillisFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd@HH:mm:ss.SSS"
    return formatter
  }()

  /// Returns this date formatted as full date and time with milliseconds
  var fullDateWithMillisString: String {
    return Self.fullDateTimeWithMillisFormatter.string(from: self)
  }
}
