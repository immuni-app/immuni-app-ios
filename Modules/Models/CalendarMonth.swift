// CalendarMonth.swift
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

import Extensions
import Foundation

/// Identifies a specific month avoiding the complexity to handle different time zones.
/// The month is identified using the bieginning of the first day of the month
public struct CalendarMonth: Codable, Equatable, Hashable, Comparable {
  /// The user's calendar but with UTC timezone
  fileprivate static var utcCalendar: Calendar {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "UTC") ?? LibLogger.fatalError("Cannot create utc calendar")
    return calendar
  }

  /// The first day of the month. The struct uses a calendar day to avoid
  /// re-implementing the underlying logic
  private let underlyingCalendarDay: CalendarDay

  public init(year: Int, month: Int) {
    assert(month <= 12)
    self.underlyingCalendarDay = CalendarDay(year: year, month: month, day: 1)
  }

  public static func < (lhs: CalendarMonth, rhs: CalendarMonth) -> Bool {
    return lhs.underlyingCalendarDay < rhs.underlyingCalendarDay
  }

  /// Number of days of `self`
  public var numberOfDays: Int {
    let dateComponents = DateComponents(year: self.underlyingCalendarDay.year, month: self.underlyingCalendarDay.month)
    let calendar = Calendar.current
    let date = calendar.date(from: dateComponents) ?? LibLogger.fatalError("Can't generate date")

    let range = calendar.range(of: .day, in: .month, for: date) ?? LibLogger.fatalError("Can't retrieve range")
    return range.count
  }

  /// Returns the next CalendarMonth
  public var next: Self {
    let dayInNextMonth = self.underlyingCalendarDay.byAdding(days: self.numberOfDays)
    return Self(year: dayInNextMonth.year, month: dayInNextMonth.month)
  }

  /// The date of the beginning of the month (UTC timezone)
  public var utcDateAtBeginningOfTheMonth: Date {
    return self.underlyingCalendarDay.utcDateAtBeginningOfTheDay
  }
}

public extension Date {
  /// Retrieves the calendar month from `self` using the utc's timezone
  var utcCalendarMonth: CalendarMonth {
    let calendar = CalendarMonth.utcCalendar
    let year = calendar.component(.year, from: self)
    let month = calendar.component(.month, from: self)

    return CalendarMonth(year: year, month: month)
  }
}
