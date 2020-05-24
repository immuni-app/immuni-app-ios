// CalendarDay.swift
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

/// Identifies a specific day avoiding the complexity to handle different time zones
public struct CalendarDay: Codable, Equatable, Hashable, Comparable {
  /// The user's calendar but with UTC timezone
  fileprivate static var utcCalendar: Calendar {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "UTC") ?? LibLogger.fatalError("Cannot create utc calendar")
    return calendar
  }

  public var year: Int
  public var month: Int
  public var day: Int

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  public static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
    guard lhs.year == rhs.year else {
      return lhs.year < rhs.year
    }

    guard lhs.month == rhs.month else {
      return lhs.month < rhs.month
    }

    return lhs.day < rhs.day
  }
}

public extension CalendarDay {
  init(date: Date) {
    let calendar = Calendar.current
    self.year = calendar.component(.year, from: date)
    self.month = calendar.component(.month, from: date)
    self.day = calendar.component(.day, from: date)
  }

  /// The Date corresponding to this CalendarDay
  /// at midnight in the user's timezone.
  var dateAtBeginningOfTheDay: Date {
    var dateComponents = DateComponents()
    dateComponents.year = self.year
    dateComponents.month = self.month
    dateComponents.day = self.day

    return Calendar.current.date(from: dateComponents)
      ?? LibLogger.fatalError("Can't perform date arithmetics")
  }

  /// The Date corresponding to this CalendarDay
  /// at midnight in the UTC's timezone.
  var utcDateAtBeginningOfTheDay: Date {
    var dateComponents = DateComponents()
    dateComponents.year = self.year
    dateComponents.month = self.month
    dateComponents.day = self.day

    return Self.utcCalendar.date(from: dateComponents)
      ?? LibLogger.fatalError("Can't perform date arithmetics")
  }

  /// Returns the number of days from `anotherDay` to `self`.
  /// Note that if `self` is **after** `anotherDay` the result will be positive.
  func daysSince(_ anotherDay: Self) -> Int {
    let thisDate = self.dateAtBeginningOfTheDay
    let otherDate = anotherDay.dateAtBeginningOfTheDay

    return Calendar.current.dateComponents([.day], from: otherDate, to: thisDate).day
      ?? LibLogger.fatalError("Can't perform date arithmetics")
  }

  /// A CalendarDay corresponding to this CalendarDay shifted by `days` days
  func byAdding(days: Int) -> Self {
    let thisDate = self.dateAtBeginningOfTheDay

    let otherDate = Calendar.current.date(byAdding: .day, value: days, to: thisDate)
      ?? LibLogger.fatalError("Can't perform date arithmetics")

    return otherDate.calendarDay
  }
}

public extension Date {
  // The calendar day in the user's timezone
  var calendarDay: CalendarDay {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: self)
    let month = calendar.component(.month, from: self)
    let day = calendar.component(.day, from: self)

    return CalendarDay(year: year, month: month, day: day)
  }

  // The calendar day in the UTC's timezone
  var utcCalendarDay: CalendarDay {
    let calendar = CalendarDay.utcCalendar
    let year = calendar.component(.year, from: self)
    let month = calendar.component(.month, from: self)
    let day = calendar.component(.day, from: self)

    return CalendarDay(year: year, month: month, day: day)
  }
}
