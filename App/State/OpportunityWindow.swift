//
//  OpportunityWindow.swift
//  Immuni
//
//  Created by LorDisturbia on 25/05/2020.
//

import Foundation
import Models

/// Defines a range of time defined by a starting moment, which is the midnight of a month,
/// a shift with respect to the starting point and a duration
struct OpportunityWindow: Codable, Equatable {
  static let secondsInDay: TimeInterval = 86400

  /// The start of this opportunity window
  let windowStart: Date

  /// The duration of the opportunity window
  let windowDuration: TimeInterval

  /// The end of this opportunity window
  var windowEnd: Date {
    return self.windowStart.addingTimeInterval(self.windowDuration)
  }

  /// The month in which the opportunity window occurs
  var month: CalendarMonth {
    return self.windowStart.utcCalendarMonth
  }

  /// Default initializer
  init(windowStart: Date, windowDuration: TimeInterval) {
    self.windowStart = windowStart
    self.windowDuration = windowDuration
  }

  /// Convenience initializer that takes a `CalendarMonth` and a shift from the beginning of said month.
  init(month: CalendarMonth, shift: TimeInterval, windowDuration: TimeInterval = Self.secondsInDay) {
    self.windowStart = month.utcDateAtBeginningOfTheMonth.addingTimeInterval(shift)
    self.windowDuration = windowDuration
  }

  /// Whether the given date falls in the opportunity window
  func contains(_ date: Date) -> Bool {
    guard self.windowDuration > 0 else {
      return false
    }

    return (self.windowStart ..< self.windowEnd).contains(date)
  }
}

// MARK: Helpers

extension OpportunityWindow {
  static var distantPast = OpportunityWindow(month: Date.distantPast.utcCalendarMonth, shift: 0, windowDuration: 0)
}
