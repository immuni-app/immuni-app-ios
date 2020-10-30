//
//  ExposureInfo+MostRecentRiskyDay.swift
//  Extensions
//
//  Created by LorDisturbia on 30/10/2020.
//

import Foundation
import Models

// MARK: - Helpers

extension Array where Element == ExposureInfo {
  /// Most recent contact day of an array of `ExposureInfo`
  public func mostRecentRiskyContactDay(closeContactRiskThreshold: Int) -> CalendarDay? {
    let mostRecentDate = self
      .filter { $0.totalRiskScore >= closeContactRiskThreshold }
      .map { $0.date }
      .max()

    return mostRecentDate?.calendarDay
  }
}

extension Array where Element == CodableExposureInfo {
  /// Most recent contact day of an array of `ExposureInfo`
  public func mostRecentRiskyContactDay(closeContactRiskThreshold: Int) -> CalendarDay? {
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
