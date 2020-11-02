// ExposureInfo+MostRecentRiskyDay.swift
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
import Models

// MARK: - Helpers

public extension Array where Element == ExposureInfo {
  /// Most recent contact day of an array of `ExposureInfo`
  func mostRecentRiskyContactDay(closeContactRiskThreshold: Int) -> CalendarDay? {
    let mostRecentDate = self
      .filter { $0.totalRiskScore >= closeContactRiskThreshold }
      .map { $0.date }
      .max()

    return mostRecentDate?.calendarDay
  }
}

public extension Array where Element == CodableExposureInfo {
  /// Most recent contact day of an array of `ExposureInfo`
  func mostRecentRiskyContactDay(closeContactRiskThreshold: Int) -> CalendarDay? {
    let maybeMostRecentContactDateString = self
      .filter { $0.totalRiskScore >= closeContactRiskThreshold }
      .map { $0.date }
      .max() // These dates are yyyy-MM-dd, so lexicographic ordering works properly

    guard let mostRecentDateString = maybeMostRecentContactDateString else {
      return nil
    }

    return Date(utcIsoString: mostRecentDateString)?.calendarDay
  }
}
