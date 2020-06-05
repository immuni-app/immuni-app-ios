// AnalyticsTokenGenerator.swift
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

protocol AnalyticsTokenGenerator {
  func generateToken(length: Int) -> String
  func nextExpirationDate() -> Date
}

struct ImmuniAnalyticsTokenGenerator: AnalyticsTokenGenerator {
  let now: () -> Date
  let uniformDistributionGenerator: UniformDistributionGenerator.Type

  func generateToken(length: Int) -> String {
    return String.random(length: length)
  }

  func nextExpirationDate() -> Date {
    let nextMonth = self.now().utcCalendarMonth.next
    let numDays = nextMonth.numberOfDays
    let maxShift = Double(numDays - 1) * OpportunityWindow.secondsInDay
    let shift = self.uniformDistributionGenerator.random(in: 0 ..< maxShift)
    return nextMonth.utcDateAtBeginningOfTheMonth.addingTimeInterval(shift)
  }
}
